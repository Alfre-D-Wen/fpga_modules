`timescale  1ns / 1ns

module arst_sync_tb;

    // arst_sync Parameters
    parameter PERIOD = 10;


    // arst_sync Inputs
    reg in_clk = 0 ;
    reg in_areset_n = 1 ;

    // arst_sync Outputs
    wire out_reset ;

    initial
    begin
        forever
            #(PERIOD / 2) in_clk = ~in_clk;
    end

    initial
    begin
        forever
            #(PERIOD * 1.2) in_areset_n = $random;
    end

    arst_sync u_arst_sync (
                  .in_clk ( in_clk ),
                  .in_areset_n ( in_areset_n ),
                  .out_reset ( out_reset )
              );

endmodule
