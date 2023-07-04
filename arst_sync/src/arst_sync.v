/************************************************************************
*  File           : arst_sync.v
*  Module Name    : arst_sync
*  Revision       : 1.0
*  Model          : 
*
*  Description    : 异步复位同步释放，其中输入复位低电平有效，输出复位高电平有效
*   
*           
*            
*  Designer       : Alfred Wen
*  Create Date    : 2023.07.03
*  Rev        Author        Date        Modification
*  ---       ---------    ---------     ---------------     
*
*
*
************************************************************************/
`timescale  1ns / 1ns
module arst_sync (
        input in_clk,
        input in_areset_n,
        output out_reset
    );

    reg reset_r;
    reg reset_d1_r;

    always @(posedge in_clk or negedge in_areset_n)
    begin
        //异步复位
        if (~in_areset_n)
        begin
            reset_r <= 1'b1;
            reset_d1_r <= 1'b1;
        end
        //同步释放
        else
        begin
            reset_r <= 1'b0;
            reset_d1_r <= reset_r;
        end
    end

    assign out_reset = reset_d1_r;

endmodule
