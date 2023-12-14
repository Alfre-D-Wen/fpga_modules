//////////////////////////////////////////////////////////////////////////////////
// Company: Concemed
// Engineer: Alfred Wen
//
// Create Date: 2023/11/01 10:34:51
// Design Name: axi_stream_gen.v
// Module Name:
// Project Name:
// Target Devices: xcku060-ffva1156-2-i / xc7a35tcsg325-1
// Tool Versions: Vivado 2021.1
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module axi_stream_gen #(
           parameter HSIZE = 1920,
           parameter VSIZE = 3,

           parameter H_BLANK = 3,

           parameter FRAME_VALID = 1
       )(
           input clk_in,
           input rst_n_in,
           input pause_in,

           input raw_data_valid_in,
           input [9:0] raw_data_in,
           input axi_tready_in,

           output data_req_out,
           output axi_tuser_out,
           output axi_tlast_out,
           output axi_tvalid_out,
           output [15:0] axi_tdata_out
       );

//--------------------------------------------------------------------------//
// internal signals
//--------------------------------------------------------------------------//
reg [15:0] pixel_cnt;
reg [15:0] line_cnt; //0~15
reg [10:0] frame_cnt;

reg axis_tvalid_r;
reg axis_tvalid_delay_r;

reg axis_tuser_r;

reg axis_tlast_r;
reg axis_tlast_delay_r;
wire axis_tlast_pe;

reg [9:0] pixel_data_r;

reg frame_end_r;

//--------------------------------------------------------------------------//
// outputs
//--------------------------------------------------------------------------//
assign axi_tuser_out = (frame_cnt == 0) && (line_cnt == 0) && (pixel_cnt == 0) && axi_tready_in && axi_tvalid_out;
assign axi_tlast_out = axis_tlast_r;
assign axi_tvalid_out = axis_tvalid_r;
assign data_req_out = axi_tready_in;
assign axi_tdata_out = {6'b0,pixel_data_r};

always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        pixel_cnt <= 'd0;
    end
    else if (pixel_cnt == HSIZE - 1)
    begin
        pixel_cnt <= 'd0;
    end
    else if (pause_in)
    begin
        pixel_cnt <= pixel_cnt;
    end
    else if (axi_tvalid_out)
    begin
        pixel_cnt <= pixel_cnt + 1'd1;
    end
    else
    begin
        pixel_cnt <= pixel_cnt;
    end
end

always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        line_cnt <= 'd0;
    end
    else if ((line_cnt == VSIZE - 1) && (axis_tlast_pe))
    begin
        line_cnt <= 'd0;
    end
    else if (axis_tlast_pe)
    begin
        line_cnt <= line_cnt + 1'd1;
    end
    else
    begin
        line_cnt <= line_cnt;
    end
end

always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        frame_end_r <= 1'b0;
    end
    else if ((line_cnt == VSIZE + H_BLANK - 1) && (pixel_cnt == HSIZE - 2))
    begin
        frame_end_r <= 1'b1;
    end
    else
    begin
        frame_end_r <= 1'b0;
    end
end

always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        frame_cnt <= 2'd0;
    end
    else if ((frame_cnt == FRAME_VALID - 1) && (frame_end_r))
    begin
        frame_cnt <= 'd0;
    end
    else if (frame_end_r)
    begin
        frame_cnt <= frame_cnt + 1'd1;
    end
    else
    begin
        frame_cnt <= frame_cnt;
    end
end

//***************************************************************************
// AXI-STREAM interface
//***************************************************************************
always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        axis_tuser_r <= 1'b0;
    end
    else if ((pixel_cnt == 0) && (line_cnt == 0))
    begin
        axis_tuser_r <= 1'b1;
    end
    else
    begin
        axis_tuser_r <= 1'b0;
    end
end

always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        axis_tlast_r <= 1'b0;
    end
    else if ((raw_data_valid_in) && (pixel_cnt == 0))
    begin
        axis_tlast_r <= 1'b0;
    end
    else if (pixel_cnt == HSIZE - 2)
    begin
        axis_tlast_r <= 1'b1;
    end
    else
    begin
        axis_tlast_r <= axis_tlast_r;
    end
end

always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        axis_tlast_delay_r <= 1'b0;
    end
    else
    begin
        axis_tlast_delay_r <= axis_tlast_r;
    end
end

assign axis_tlast_pe = axis_tlast_r && (~axis_tlast_delay_r);

always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        axis_tvalid_r <= 1'b0;
        axis_tvalid_delay_r <= axis_tvalid_r;
    end
    else
    begin
        axis_tvalid_r <= raw_data_valid_in;
        axis_tvalid_delay_r <= axis_tvalid_r;
    end
end

always@(posedge clk_in or negedge rst_n_in )
begin
    if (~rst_n_in)
    begin
        pixel_data_r <= 10'b0;
    end
    else if (raw_data_valid_in)
    begin
        pixel_data_r <= raw_data_in;
    end
end

endmodule
