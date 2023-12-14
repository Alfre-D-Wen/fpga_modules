`timescale 1ns/1ps
module result_checker#(
           parameter DATA_WIDTH = 10,
           parameter HSIZE = 6,
           parameter VSIZE = 6
       )
       (
           input clk_in,
           input rst_n_in,

           input m_axis_tlast,
           input m_axis_tuser,
           input m_axis_tvalid,
           input m_axis_tready,
           input [15:0] m_axis_tdata,

           output error_check
       );

//--------------------------------------------------------------------------//
// internal signals
//--------------------------------------------------------------------------//
reg [DATA_WIDTH - 1:0] data_matlab_r;
reg [31:0] data_addr_r;
reg [DATA_WIDTH - 1:0] data_matrix_r [HSIZE*VSIZE - 1:0];

reg [11:0] pixel_cnt_r;
reg [11:0] line_cnt_r;

reg [9:0] m_axis_tdata_r;

reg [9:0] data_deviation_r;

reg [1:0] m_axis_tvalid_delay_r;
reg [1:0] m_axis_tready_delay_r;

/* wire r_compare_valid;
wire g_compare_valid;
wire b_compare_valid;
 
reg [9:0] r_addr_r;
reg [9:0] g_addr_r;
reg [9:0] b_addr_r; */

initial
begin
    $readmemh ("../../../../user_srcs/tb/sim_new_data_6.txt", data_matrix_r, 0);
    //$readmemh ("../../../../user_srcs/tb/dark_calc.txt", data_matrix_r, 0);
end

//--------------------------------------------------------------------------//
// outputs
//--------------------------------------------------------------------------//
assign error_check = ((!m_axis_tvalid_delay_r[1]) || (!m_axis_tready_delay_r[1]))?1'b0:(1 >= data_deviation_r )?1'b0:1'b1;

//--------------------------------------------------------------------------//
// pixel_cnt
//--------------------------------------------------------------------------//
always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        pixel_cnt_r <= 'd0;
    end
    else if (pixel_cnt_r == VSIZE)
    begin
        pixel_cnt_r <= 'd0;
    end
    else if (m_axis_tvalid)
    begin
        pixel_cnt_r <= pixel_cnt_r + 1'd1;
    end
    else
    begin
        pixel_cnt_r <= pixel_cnt_r;
    end
end

//--------------------------------------------------------------------------//
// line_cnt
//--------------------------------------------------------------------------//
always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        line_cnt_r <= 'd0;
    end
    else if (m_axis_tlast && (line_cnt_r == HSIZE - 1))
    begin
        line_cnt_r <= 'd0;
    end
    else if (m_axis_tlast)
    begin
        line_cnt_r <= line_cnt_r + 1'd1;
    end
    else
    begin
        line_cnt_r <= line_cnt_r;
    end
end

//--------------------------------------------------------------------------//
// tvalid_delay
//--------------------------------------------------------------------------//
always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        m_axis_tvalid_delay_r <= 2'b0;
    end
    else if (m_axis_tvalid)
    begin
        m_axis_tvalid_delay_r <= {m_axis_tvalid_delay_r[0],m_axis_tvalid};
    end
    else
    begin
        m_axis_tvalid_delay_r <= {m_axis_tvalid_delay_r[0],1'b0};
    end
end

//--------------------------------------------------------------------------//
// tready_delay
//--------------------------------------------------------------------------//
always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        m_axis_tready_delay_r <= 2'b0;
    end
    else if (m_axis_tready)
    begin
        m_axis_tready_delay_r <= {m_axis_tready_delay_r[0],m_axis_tready};
    end
    else
    begin
        m_axis_tready_delay_r <= {m_axis_tready_delay_r[0],1'b0};
    end
end
//--------------------------------------------------------------------------//
// compare valid
//--------------------------------------------------------------------------//
/* assign r_compare_valid = ((m_axis_tvalid)&&(line_cnt_r==0))?1'b1:1'b0;
assign g_compare_valid = ((m_axis_tvalid)&&(line_cnt_r==1))?1'b1:1'b0;
assign b_compare_valid = ((m_axis_tvalid)&&(line_cnt_r==2))?1'b1:1'b0; */

//***************************************************************************
// input data split
//***************************************************************************
always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        m_axis_tdata_r <= 10'd0;
    end
    else
    begin
        m_axis_tdata_r <= m_axis_tdata[9:0];
    end
end

//***************************************************************************
// read data from .txt file
//***************************************************************************
always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        data_addr_r <= 'd0;
    end
    else if (data_addr_r == (HSIZE * VSIZE - 1))
    begin
        data_addr_r <= 'd0;
    end
    else if ((m_axis_tvalid)&&(m_axis_tready))
    begin
        data_addr_r <= data_addr_r + 1'd1;
    end
    else
    begin
        data_addr_r <= data_addr_r;
    end
end

always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        data_matlab_r <= 'd0;
    end
    else if ((m_axis_tvalid)&&(m_axis_tready))
    begin
        data_matlab_r <= data_matrix_r[data_addr_r];
    end
end

//***************************************************************************
// calc deviation
//***************************************************************************
always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        data_deviation_r <= 10'd0;
    end
    else if (m_axis_tvalid_delay_r[1])
    begin
        data_deviation_r <= ~(m_axis_tdata_r + ((~data_matlab_r) + 1)) + 1;
    end
    else
    begin
        data_deviation_r <= 10'd0;
    end
end

endmodule
