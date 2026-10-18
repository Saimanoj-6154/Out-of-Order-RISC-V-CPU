module decoder import ooo_riscv_pkg::*; (
    input  logic [31:0] instruction,
    input  logic [31:0] pc,
    output decoded_instr_t d
);

  logic [6:0] opcode;
  logic [2:0] funct3;
  logic [6:0] funct7;

  always_comb begin
    opcode = instruction[6:0];
    funct3 = instruction[14:12];
    funct7 = instruction[31:25];

    d = '0;
    d.valid       = 1'b1;
    d.pc          = pc;
    d.instruction = instruction;
    d.opcode      = opcode;
    d.rd          = instruction[11:7];
    d.rs1         = instruction[19:15];
    d.rs2         = instruction[24:20];
    d.funct3      = funct3;
    d.alu_op      = OP_ADD;

    case (opcode)

      // Register-register operations
      7'b0110011: begin
        d.writes_rd = 1'b1;
        d.uses_rs1  = 1'b1;
        d.uses_rs2  = 1'b1;

        if (funct7 == 7'b0000001) begin
          case (funct3)
            3'b000: d.alu_op = OP_MUL;
            3'b100: d.alu_op = OP_DIV;
            3'b110: d.alu_op = OP_REM;
            default: d.valid = 1'b0;
          endcase
        end else begin
          case ({funct7[5], funct3})
            4'b0000: d.alu_op = OP_ADD;
            4'b1000: d.alu_op = OP_SUB;
            4'b0001: d.alu_op = OP_SLL;
            4'b0010: d.alu_op = OP_SLT;
            4'b0011: d.alu_op = OP_SLTU;
            4'b0100: d.alu_op = OP_XOR;
            4'b0101: d.alu_op = OP_SRL;
            4'b1101: d.alu_op = OP_SRA;
            4'b0110: d.alu_op = OP_OR;
            4'b0111: d.alu_op = OP_AND;
            default: d.valid = 1'b0;
          endcase
        end
      end

      // Immediate arithmetic
      7'b0010011: begin
        d.writes_rd = 1'b1;
        d.uses_rs1  = 1'b1;
        d.immediate = {{20{instruction[31]}},
                        instruction[31:20]};

        case (funct3)
          3'b000: d.alu_op = OP_ADD;
          3'b010: d.alu_op = OP_SLT;
          3'b011: d.alu_op = OP_SLTU;
          3'b100: d.alu_op = OP_XOR;
          3'b110: d.alu_op = OP_OR;
          3'b111: d.alu_op = OP_AND;
          3'b001: begin
            d.alu_op = OP_SLL;
            if (funct7 != 7'b0000000)
              d.valid = 1'b0;
          end
          3'b101: begin
            if (funct7 == 7'b0000000)
              d.alu_op = OP_SRL;
            else if (funct7 == 7'b0100000)
              d.alu_op = OP_SRA;
            else
              d.valid = 1'b0;
          end
          default: d.valid = 1'b0;
        endcase
      end

      // Loads
      7'b0000011: begin
        d.writes_rd = 1'b1;
        d.uses_rs1  = 1'b1;
        d.is_load   = 1'b1;
        d.immediate = {{20{instruction[31]}},
                        instruction[31:20]};
        d.alu_op    = OP_ADD;
      end

      // Stores
      7'b0100011: begin
        d.uses_rs1  = 1'b1;
        d.uses_rs2  = 1'b1;
        d.is_store  = 1'b1;
        d.immediate = {{20{instruction[31]}},
                        instruction[31:25],
                        instruction[11:7]};
        d.alu_op = OP_ADD;
      end

      // Conditional branches
      7'b1100011: begin
        d.uses_rs1  = 1'b1;
        d.uses_rs2  = 1'b1;
        d.is_branch = 1'b1;

        d.immediate = {
          {19{instruction[31]}},
          instruction[31],
          instruction[7],
          instruction[30:25],
          instruction[11:8],
          1'b0
        };

        case (funct3)
          3'b000, 3'b001,
          3'b100, 3'b101,
          3'b110, 3'b111: d.valid = 1'b1;
          default: d.valid = 1'b0;
        endcase
      end

      // JAL
      7'b1101111: begin
        d.writes_rd = 1'b1;
        d.is_jal    = 1'b1;

        d.immediate = {
          {11{instruction[31]}},
          instruction[31],
          instruction[19:12],
          instruction[20],
          instruction[30:21],
          1'b0
        };
      end

      // JALR
      7'b1100111: begin
        d.writes_rd = 1'b1;
        d.uses_rs1  = 1'b1;
        d.is_jalr   = 1'b1;
        d.immediate = {{20{instruction[31]}},
                        instruction[31:20]};

        if (funct3 != 3'b000)
          d.valid = 1'b0;
      end

      // LUI
      7'b0110111: begin
        d.writes_rd = 1'b1;
        d.immediate = {instruction[31:12], 12'b0};
        d.alu_op = OP_PASS;
      end

      // AUIPC
      7'b0010111: begin
        d.writes_rd = 1'b1;
        d.immediate = {instruction[31:12], 12'b0};
        d.alu_op = OP_ADD;
      end

      default: d.valid = 1'b0;

    endcase
  end

endmodule