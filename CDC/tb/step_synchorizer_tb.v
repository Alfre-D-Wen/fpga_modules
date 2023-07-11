`timescale  1ns / 1ns

module step_synchorizer_tb;

    // synchorizer Parameters
    parameter SEND_PERIOD = 22;
    parameter RECEIVE_PERIOD = 10;
    parameter DELAY_CYCLES = 2;

    // synchorizer Inputs
    reg in_clk_send = 0 ;
    reg in_data = 0 ;
    reg in_clk_receive = 0 ;

    // synchorizer Outputs
    wire out_data_delay ;

    initial
    begin
        forever
            #(SEND_PERIOD / 2) in_clk_send = ~in_clk_send;
    end

    initial
    begin
        forever
            #(RECEIVE_PERIOD / 2) in_clk_receive = ~in_clk_receive;
    end

    always @(posedge in_clk_send )
    begin
        in_data <= $random;
    end

    step_synchorizer #(
                         .DELAY_CYCLES ( DELAY_CYCLES ))
                     u_step_synchorizer (
                         .in_clk_send ( in_clk_send ),
                         .in_data ( in_data ),
                         .in_clk_receive ( in_clk_receive ),

                         .out_data_delay ( out_data_delay )
                     );

endmodule
