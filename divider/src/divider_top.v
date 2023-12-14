`timescale 1ns/1ns
module divider_top #(
        parameter DIVIDEND_WIDTH = 8,
        parameter DIVIDER_WIDTH = 8
    ) (
        input in_clk,
        input in_data_valid,
        input [DIVIDEND_WIDTH - 1: 0] in_dividend,
        input [DIVIDER_WIDTH - 1: 0] in_divider,
        output out_data_valid,
        output [DIVIDEND_WIDTH - 1: 0] out_quotient,
        output [DIVIDER_WIDTH - 1: 0] out_remainder
    );

    //!�Ա�������λ��2��λ��,һ������ DIVIDEND_WIDTH - 1 ��λ��Ϊ
    wire [2 * DIVIDEND_WIDTH - 1: 0] dividend_expand_r [DIVIDEND_WIDTH : 0] ;
    //!�Գ�����λ��������2��λ��
    wire [2 * DIVIDEND_WIDTH - 1: 0] divider_expand_r [DIVIDEND_WIDTH : 0] ;
    //!��in_data_valid�����ӳ�
    reg [DIVIDEND_WIDTH - 1: 0] data_ready_delay_r;

    //!�Ա�����������������λ
    assign dividend_expand_r[0] = {{DIVIDEND_WIDTH{1'b0}}, in_dividend};
    assign divider_expand_r[0] = {in_divider, {DIVIDEND_WIDTH{1'b0}}};

    //!��������λ����������
    genvar shift_cnt;
    generate
        for (shift_cnt = 1; shift_cnt <= DIVIDEND_WIDTH; shift_cnt = shift_cnt + 1)
        begin: shift_comparator
            shift_comparator
                #(
                    .DIVIDEND_WIDTH (DIVIDEND_WIDTH ),
                    .DIVIDER_WIDTH (DIVIDER_WIDTH )
                )
                u_shift_comparator(
                    .in_clk (in_clk ),
                    .in_dividend_expand (dividend_expand_r[shift_cnt - 1] ),
                    .in_divider_expand (divider_expand_r[shift_cnt - 1] ),
                    .out_new_dividend_expand_r (dividend_expand_r[shift_cnt] ),
                    .out_new_divider_expand_r (divider_expand_r[shift_cnt] )
                );
        end
    endgenerate

    //!�����Ч�ź�
    always @(posedge in_clk)
    begin
        if (in_data_valid)
        begin
            data_ready_delay_r <= {data_ready_delay_r[DIVIDEND_WIDTH - 2: 0], in_data_valid};
        end
        else
        begin
            data_ready_delay_r <= {data_ready_delay_r[DIVIDEND_WIDTH - 2: 0], 1'b0};
        end
    end

    assign out_data_valid = data_ready_delay_r[DIVIDEND_WIDTH - 1];
    assign out_quotient = dividend_expand_r[DIVIDEND_WIDTH][DIVIDEND_WIDTH - 1 : 0];
    assign out_remainder = dividend_expand_r[DIVIDEND_WIDTH][2 * DIVIDEND_WIDTH - 1: DIVIDEND_WIDTH];

endmodule
