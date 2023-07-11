`timescale  1ns / 1ps

module feedback_synchorizer_tb;

    // feedback_synchorizer Parameters
    parameter SEND_PERIOD = 10;
    parameter RECEIVE_PERIOD = 22;


    // feedback_synchorizer Inputs
    reg in_clk_send = 0 ;
    reg in_data = 0 ;
    reg in_clk_receive = 0 ;

    // feedback_synchorizer Outputs
    wire out_data ;

    wire reset_send;
    wire reset_receive;

    reg in_areset_n = 1;
    reg [7: 0] cnt;

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

    initial
    begin
        # (2.3 * SEND_PERIOD) in_areset_n = 0;
        # (1.5 * SEND_PERIOD) in_areset_n = 1;
    end

    always @(posedge in_clk_send or posedge reset_send)
    begin
        if (reset_send)
        begin
            cnt = 'd0;
        end
        else if (cnt == 'd99)
        begin
            cnt <= 'd0;
        end
        else
        begin
            cnt <= cnt + 1'd1;
        end
    end

    always @(posedge in_clk_send )
    begin
        if (cnt == 5 || cnt == 40 || cnt == 42 || (cnt >= 75 && cnt <= 81) || cnt == 85 || cnt == 87 )
        begin
            in_data <= 1'd1;
        end
        else
        begin
            in_data <= 1'd0;
        end
    end

    arst_sync U0_arst_sync(
                  .in_clk (in_clk_send ),
                  .in_areset_n (in_areset_n ),
                  .out_reset (reset_send )
              );

    arst_sync U1_arst_sync(
                  .in_clk (in_clk_receive ),
                  .in_areset_n (in_areset_n ),
                  .out_reset (reset_receive )
              );


    feedback_synchorizer U_feedback_synchorizer (
                             .in_clk_send ( in_clk_send ),
                             .in_data ( in_data ),
                             .in_reset_send ( reset_send ),
                             .in_reset_receive ( reset_receive ),
                             .in_clk_receive ( in_clk_receive ),

                             .out_data ( out_data )
                         );

endmodule
