//////////////////////////////////////////////////////////////////////////////////
// Company: Concemed
// Engineer: Alfred Wen
//
// Create Date: 2023/08/04 13:49:21
// Design Name: step_synchronizer.v
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
module step_synchorizer #(
        //!同步器延时数，该值>=1
        parameter DELAY_CYCLES = 2
    ) (
        input in_clk_send,
        input in_data,
        input in_clk_receive,
        output out_data_delay
    );

    reg [DELAY_CYCLES : 0] data_delay_r;

    always @(posedge in_clk_receive )
    begin
        if (in_data)
        begin
            data_delay_r <= {data_delay_r[DELAY_CYCLES - 1: 0], in_data};
        end
        else
        begin
            data_delay_r <= {data_delay_r[DELAY_CYCLES - 1: 0], 1'b0};
        end
    end

    assign out_data_delay = data_delay_r[DELAY_CYCLES];
endmodule
