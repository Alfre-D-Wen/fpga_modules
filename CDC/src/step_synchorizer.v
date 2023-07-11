/************************************************************************
*  File           : step_synchorizer.v
*  Module Name    : step_synchorizer
*  Revision       : 1.0
*  Model          : 
*
*  Description    : 同步器，用于慢时钟域->快时钟域的单比特数据同步
*   
*           
*            
*  Designer       : Alfred Wen
*  Create Date    : 2023.07.10
*  Rev        Author        Date        Modification
*  ---       ---------    ---------     ---------------     
*
*
*
************************************************************************/
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
