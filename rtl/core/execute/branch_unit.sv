module branch_unit (
    input  logic [31:0] pc,
    input  logic [31:0] immediate,
    input  logic [31:0] lhs,
    input  logic [31:0] rhs,
    input  logic [2:0]  funct3,

    input  logic is_branch,
    input  logic is_jal,
    input  logic is_jalr,

    output logic taken,
    output logic [31:0] target
);

  always_comb begin
    taken = is_jal || is_jalr;

    if (is_branch) begin
      case (funct3)
        3'b000: taken = (lhs == rhs);
        3'b001: taken = (lhs != rhs);
        3'b100: taken = ($signed(lhs) < $signed(rhs));
        3'b101: taken = ($signed(lhs) >= $signed(rhs));
        3'b110: taken = (lhs < rhs);
        3'b111: taken = (lhs >= rhs);
        default: taken = 1'b0;
      endcase
    end

    if (is_jalr)
      target = (lhs + immediate) & 32'hFFFF_FFFE;
    else
      target = pc + immediate;
  end

endmodule