module div_datapath #(
    parameter ITERS_PER_CYCLE = 1
)(
    input  logic        clk,
    input  logic        rst,

    input  logic        load,
    input  logic        iterate,
    input  logic        finish,

    input  logic        is_signed, 

    input  logic [31:0] dividend,
    input  logic [31:0] divisor,

    input  logic        special_case,
    input  logic [31:0] special_q,
    input  logic [31:0] special_r,

    output logic [31:0] quotient,
    output logic [31:0] remainder
);

    logic [31:0] divisor_abs;
    logic [31:0] q;
    logic [32:0] r;
                logic [32:0] r_tmp;
                logic [31:0] q_tmp;
    logic sign_q;
    logic sign_r;

    function automatic [31:0] abs32(input logic [31:0] x);
        abs32 = x[31] ? -x : x;
    endfunction

    // Sequential datapath
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            q         <= 0;
            r         <= 0;
            divisor_abs <= 0;
            sign_q    <= 0;
            sign_r    <= 0;
            quotient  <= 0;
            remainder <= 0;
        end
        else begin
            if (load) begin
                if (is_signed) begin
                    q           <= abs32(dividend);
                    divisor_abs <= abs32(divisor);
                    sign_q      <= dividend[31] ^ divisor[31];
                    sign_r      <= dividend[31];
                end
                else begin
                    q           <= dividend;
                    divisor_abs <= divisor;
                    sign_q      <= 0;
                    sign_r      <= 0;
                end
                r <= 0;
            end
            else if (iterate || finish) begin
                // Always compute the iteration result
                r_tmp = r;
                q_tmp = q;
                for (int i = 0; i < ITERS_PER_CYCLE; i++) begin
                    r_tmp = {r_tmp[31:0], q_tmp[31]};
                    q_tmp = {q_tmp[30:0], 1'b0};
                    if (r_tmp >= {1'b0, divisor_abs}) begin
                        r_tmp = r_tmp - {1'b0, divisor_abs};
                        q_tmp[0] = 1'b1;
                    end
                end
                r <= r_tmp;
                q <= q_tmp;

                // On finish, save final result from q_tmp/r_tmp (not q/r)
                if (finish) begin
                    if (special_case) begin
                        quotient  <= special_q;
                        remainder <= special_r;
                    end
                    else if (is_signed) begin
                        quotient  <= sign_q ? -q_tmp[31:0] : q_tmp[31:0];
                        remainder <= sign_r ? -r_tmp[31:0] : r_tmp[31:0];
                    end
                    else begin
                        quotient  <= q_tmp[31:0];
                        remainder <= r_tmp[31:0];
                    end
                end
            end
            
            // Special case finishes without an iterate cycle
            else if (finish) begin
                quotient  <= special_q;
                remainder <= special_r;
            end
        end
    end

endmodule
