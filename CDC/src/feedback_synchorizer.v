//////////////////////////////////////////////////////////////////////////////////
// Company: Concemed
// Engineer: Alfred Wen
//
// Create Date: 2023/08/04 10:28:02
// Design Name: feedback_synchronizer.v
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
`timescale 1ns/1ns
module feedback_synchorizer(
        input in_clk_send,
        input in_data,
        input in_reset_send,
        input in_clk_receive,
        input in_reset_receive,
        output out_data
    );

    reg send_data_r;
    reg send_data_r_d1;
    reg send_data_ack_r;
    reg send_data_ack_d1_r;
    reg receive_data_r;
    reg receive_data_d1_r;

    /**************************SEND_DOMAIN***********************************/
    //!send_data_r & send_data_r_d1
    always @(posedge in_clk_send or posedge in_reset_send)
    begin
        if (in_reset_send)
        begin
            send_data_r <= 1'b0;
            send_data_r_d1 <= send_data_r;
        end
        else if (in_data)
        begin
            send_data_r <= 1'b1;
            send_data_r_d1 <= send_data_r;
        end
        else if (send_data_ack_d1_r)
        begin
            send_data_r <= 1'b0;
            send_data_r_d1 <= send_data_r;
        end
        else
        begin
            send_data_r <= send_data_r;
            send_data_r_d1 <= send_data_r;
        end
    end

    //!send_data_ack_r
    always @(posedge in_clk_send or posedge in_reset_send)
    begin
        if (in_reset_send)
        begin
            send_data_ack_r <= 1'b0;
            send_data_ack_d1_r <= 1'b0;
        end
        else
        begin
            send_data_ack_r <= receive_data_d1_r;
            send_data_ack_d1_r <= send_data_ack_r;
        end
    end
    /**************************RECEIVE_DOMAIN***********************************/
    //!receive_data_r,receive_data
    always @(posedge in_clk_receive or posedge in_reset_receive)
    begin
        if (in_reset_receive)
        begin
            receive_data_r <= 1'b0;
            receive_data_d1_r <= 1'b0;
        end
        else
        begin
            receive_data_r <= send_data_r_d1;
            receive_data_d1_r <= receive_data_r;
        end
    end

    //!out_data
    assign out_data = receive_data_d1_r;

endmodule
