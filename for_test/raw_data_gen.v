`define READ_FILE
module raw_data_gen #(
           parameter DATA_WIDTH = 10,
           parameter HSIZE = 6,
           parameter VSIZE = 6,


           parameter H_BLANK = 3,
           parameter V_BLANK = 0,

           parameter FRAME_VALID = 1
       )
       (
           input clk_in,
           input rst_n_in,
           input data_req_in,

           output data_valid_out,
           output [DATA_WIDTH - 1:0] data_out
       );

reg [11:0] pixel_cnt_r;
reg [11:0] line_cnt_r;
reg [11:0] frame_cnt_r;

reg data_valid_r;
reg data_valid_d1_r;
reg [DATA_WIDTH - 1:0] data_r;
reg [31:0] data_addr_r;
reg [DATA_WIDTH - 1:0] data_matrix_r [VSIZE*HSIZE - 1:0];

assign data_out = data_r;
assign data_valid_out = data_valid_d1_r;

`ifdef READ_FILE
initial
begin
    $readmemh ("../../../../user_srcs/tb/sim_raw_data_6.txt", data_matrix_r, 0);
    //$readmemh ("../../../../user_srcs/tb/dark_raw.txt", data_matrix_r, 0);
end
`endif

//***************************************************************************
// generate counters
//***************************************************************************
always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        pixel_cnt_r <= 12'd0;
    end
    else if (pixel_cnt_r == HSIZE + H_BLANK - 1)
    begin
        pixel_cnt_r <= 12'd0;
    end
    else if (data_req_in)
    begin
        pixel_cnt_r <= pixel_cnt_r + 1;
    end
    else
    begin
        pixel_cnt_r <= pixel_cnt_r;
    end
end

always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        line_cnt_r <= 12'd0;
    end
    else if ((line_cnt_r == VSIZE + V_BLANK - 1) && (pixel_cnt_r == HSIZE + H_BLANK - 1))
    begin
        line_cnt_r <= 12'd0;
    end
    else if (pixel_cnt_r == HSIZE + H_BLANK - 1)
    begin
        line_cnt_r <= line_cnt_r + 1'd1;
    end
    else
    begin
        line_cnt_r <= line_cnt_r;
    end
end

always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        frame_cnt_r <= 12'd0;
    end
    else if ((line_cnt_r == VSIZE + V_BLANK - 1) && (pixel_cnt_r == HSIZE + H_BLANK - 1) && (frame_cnt_r == FRAME_VALID - 1))
    begin
        frame_cnt_r <= 12'd0;
    end
    else if ((line_cnt_r == VSIZE + V_BLANK - 1) && (pixel_cnt_r == HSIZE + H_BLANK - 1))
    begin
        frame_cnt_r <= frame_cnt_r + 1'd1;
    end
    else
    begin
        frame_cnt_r <= frame_cnt_r;
    end
end

//***************************************************************************
// generate raw data
//***************************************************************************
always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        data_addr_r <= 'd0;
    end
    else if (data_addr_r == (VSIZE * HSIZE - 1))
    begin
        data_addr_r <= 'd0;
    end
    else if (data_valid_r)
    begin
        data_addr_r <= data_addr_r + 1'd1;
    end
    else
    begin
        data_addr_r <= data_addr_r;
    end
end

`ifdef READ_FILE
always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        data_r <= 'd0;
    end
    else
    begin
        data_r <= data_matrix_r[data_addr_r];
    end
end
`else
always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        data_r <= 'd0;
    end
    else if ((data_r == 896) && (pixel_cnt_r == 0))
    begin
        data_r <= 'd0;
    end
    else if (data_valid_r)
    begin
        data_r <= data_r + 1'd1;
    end
    else
    begin
        data_r <= data_r;
    end
end
`endif

always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        data_valid_r <= 1'b0;
    end
    else if (~data_req_in)
        begin
            data_valid_r <= 1'b0;
        end
    else if (data_req_in)
    begin
        if ((frame_cnt_r > FRAME_VALID) ||  (line_cnt_r > VSIZE - 1 ) || (pixel_cnt_r > HSIZE))
        begin
            data_valid_r <= 1'b0;
        end
        else if (pixel_cnt_r >= 1)
        begin
            data_valid_r <= 1'b1;
        end
        else
            begin
                data_valid_r <= data_valid_r;
            end
    end
end

always@(posedge clk_in)
begin
    if (~rst_n_in)
    begin
        data_valid_d1_r <= 1'b0;
    end
    else
    begin
        data_valid_d1_r <= data_valid_r;
    end
end

endmodule
