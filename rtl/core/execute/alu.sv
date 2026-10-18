module alu import ooo_riscv_pkg::*; (
    input  alu_op_t      op,
    input  logic [31:0]  a,
    input  logic [31:0]  b,
    output logic [31:0]  y,
    output logic         divide_by_zero
);

  always_comb begin
    y = 32'b0;
    divide_by_zero = 1'b0;

    case (op)
      OP_ADD:  y = a + b;
      OP_SUB:  y = a - b;
      OP_AND:  y = a & b;
      OP_OR:   y = a | b;
      OP_XOR:  y = a ^ b;

      OP_SLL:  y = a << b[4:0];
      OP_SRL:  y = a >> b[4:0];
      OP_SRA:  y = $signed(a) >>> b[4:0];

      OP_SLT:
        y = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;

      OP_SLTU:
        y = (a < b) ? 32'd1 : 32'd0;

      OP_MUL:
        y = a * b;

      OP_DIV: begin
        if (b == 0) begin
          y = 32'hFFFF_FFFF;
          divide_by_zero = 1'b1;
        end else if (
          a == 32'h8000_0000 &&
          b == 32'hFFFF_FFFF
        ) begin
          y = a;
        end else begin
          y = $signed(a) / $signed(b);
        end
      end

      OP_REM: begin
        if (b == 0) begin
          y = a;
          divide_by_zero = 1'b1;
        end else if (
          a == 32'h8000_0000 &&
          b == 32'hFFFF_FFFF
        ) begin
          y = 32'b0;
        end else begin
          y = $signed(a) % $signed(b);
        end
      end

      OP_PASS:
        y = b;

      default:
        y = 32'b0;
    endcase
  end

endmodule