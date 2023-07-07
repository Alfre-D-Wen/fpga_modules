`timescale  1ns / 1ns
module divider_tb;

    // divider_top Parameters
    parameter PERIOD = 10;
    parameter DIVIDEND_WIDTH = 8;
    parameter DIVIDER_WIDTH = 8;

    // 除数，被除数 随机生成范围
    parameter DIVIDEND_MAX = 255;
    parameter DIVIDEND_MIN = 1;
    parameter DIVIDER_MAX = 255;
    parameter DIVIDER_MIN = 1;

    // divider_tb Inputs
    reg in_clk = 0 ;
    reg in_reset_n = 1 ;
    reg in_data_valid = 0;
    reg [DIVIDEND_WIDTH - 1: 0] in_dividend = 0 ;
    reg [DIVIDER_WIDTH - 1: 0] in_divider = 0 ;

    // divider_tb Outputs
    wire out_data_valid ;
    wire [DIVIDEND_WIDTH - 1: 0] out_quotient ;
    wire [DIVIDER_WIDTH - 1: 0] out_remainder ;
    wire out_error_flag;

    //arst_sync <-> divider_top
    wire reset;

    //divider_tb
    wire [DIVIDEND_WIDTH - 1: 0]quotient;
    wire [DIVIDER_WIDTH - 1: 0] remainder;
    reg [DIVIDEND_WIDTH * DIVIDEND_WIDTH - 1: 0] quotient_delay_r;
    reg [DIVIDEND_WIDTH * DIVIDEND_WIDTH - 1: 0] remainder_delay_r;

    initial
    begin
        forever
            #(PERIOD / 2) in_clk = ~in_clk;
    end

    initial
    begin
        #(PERIOD * 2.4) in_reset_n = 0;
        #PERIOD in_reset_n = 1;
    end

    always @(posedge in_clk )
    begin
        if (reset)
        begin
            in_dividend <= 'd0;
            in_divider <= 'd0;
        end
        else
        begin
            //生成随机被除数
            in_dividend <= DIVIDEND_MIN + {$random()} % (DIVIDEND_MAX - DIVIDEND_MIN);
            //生成随机除数
            in_divider <= DIVIDER_MIN + {$random()} % (DIVIDER_MAX - DIVIDER_MIN);
        end
    end

    assign quotient = (in_data_valid) ? (in_dividend / in_divider) : 'd0;
    assign remainder = (in_data_valid) ? (in_dividend % in_divider) : 'd0;

    always @(posedge in_clk )
    begin
        begin
            quotient_delay_r <= {quotient_delay_r[DIVIDEND_WIDTH * DIVIDEND_WIDTH - 4: 0], quotient};
            remainder_delay_r <= {remainder_delay_r[DIVIDEND_WIDTH * DIVIDEND_WIDTH - 4: 0], remainder};
        end
    end

    always @(posedge in_clk)
    begin
        if (reset)
        begin
            in_data_valid <= 1'b0;
        end
        else
        begin
            in_data_valid <= 1'b1;
        end
    end

    //!结果与原被除数和除数进行验证
    assign out_error_flag = (out_data_valid == 1'b0) ? 1'b0
           : ((quotient_delay_r[DIVIDEND_WIDTH * DIVIDEND_WIDTH - 1 : DIVIDEND_WIDTH * DIVIDEND_WIDTH - DIVIDEND_WIDTH] == out_quotient) && (remainder_delay_r[DIVIDEND_WIDTH * DIVIDEND_WIDTH - 1 : DIVIDEND_WIDTH * DIVIDEND_WIDTH - DIVIDEND_WIDTH] == out_remainder)) ? 1'b0
           : 1'b1;

    arst_sync u_arst_sync(
                  .in_clk (in_clk ),
                  .in_areset_n (in_reset_n ),
                  .out_reset (reset )
              );

    divider_top #(
                    .DIVIDEND_WIDTH ( DIVIDEND_WIDTH ),
                    .DIVIDER_WIDTH ( DIVIDER_WIDTH ))
                u_divider_top (
                    .in_clk ( in_clk ),
                    .in_reset ( reset ),
                    .in_data_valid ( in_data_valid ),
                    .in_dividend ( in_dividend [DIVIDEND_WIDTH - 1: 0] ),
                    .in_divider ( in_divider [DIVIDER_WIDTH - 1: 0] ),
                    .out_data_valid ( out_data_valid ),
                    .out_quotient (out_quotient ),
                    .out_remainder (out_remainder )
                );
endmodule
