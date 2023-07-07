/************************************************************************
*  File           : shift_comparator.v
*  Module Name    : divider
*  Revision       : 1.0
*  Model          : 
*
*  Description    : 移位比较器，功能是将被除数先移位，再与除数比较，如果大于等于除
*                   数，则新被除数=原被除数-除数+1，否则新被除数=原被除数
*                 
*   
*               
*  Designer       : Alfred Wen
*  Create Date    : 2023.07.04
*  Rev        Author        Date        Modification
*  ---       ---------    ---------     ---------------     
*
*
*
************************************************************************/
`timescale 1ns/1ns
module shift_comparator #(
        parameter DIVIDEND_WIDTH = 8,
        parameter DIVIDER_WIDTH = 8
    ) (
        input in_clk,
        input [2 * DIVIDEND_WIDTH - 1: 0] in_dividend_expand,
        input [2 * DIVIDEND_WIDTH - 1: 0] in_divider_expand,
        output reg [2 * DIVIDEND_WIDTH - 1: 0] out_new_dividend_expand_r,
        output reg [2 * DIVIDEND_WIDTH - 1: 0] out_new_divider_expand_r
    );

    always @(posedge in_clk)
    begin
        //!将被除数左移1位,与除数作比较
        if ((in_dividend_expand << 1) >= in_divider_expand)
        begin
            out_new_dividend_expand_r <= (in_dividend_expand << 1) - in_divider_expand + 1'b1;
        end
        else
        begin
            out_new_dividend_expand_r <= in_dividend_expand << 1;
        end
    end

    always @(posedge in_clk )
    begin
        out_new_divider_expand_r <= in_divider_expand;
    end

endmodule
