`ifndef OOO_RISCV_DEFINITIONS_SVH
`define OOO_RISCV_DEFINITIONS_SVH

package ooo_riscv_pkg;

  parameter int XLEN        = 32;
  parameter int ARCH_REGS   = 32;
  parameter int PHYS_REGS   = 64;
  parameter int ROB_ENTRIES = 16;
  parameter int RS_ENTRIES  = 8;

  typedef enum logic [3:0] {
    OP_ADD,
    OP_SUB,
    OP_AND,
    OP_OR,
    OP_XOR,
    OP_SLL,
    OP_SRL,
    OP_SRA,
    OP_SLT,
    OP_SLTU,
    OP_MUL,
    OP_DIV,
    OP_REM,
    OP_PASS
  } alu_op_t;

  typedef struct packed {
    logic        valid;
    logic [31:0] pc;
    logic [31:0] instruction;

    logic [4:0]  rd;
    logic [4:0]  rs1;
    logic [4:0]  rs2;

    logic        writes_rd;
    logic        uses_rs1;
    logic        uses_rs2;

    logic        is_load;
    logic        is_store;
    logic        is_branch;
    logic        is_jal;
    logic        is_jalr;

    logic [2:0]  funct3;
    logic [6:0]  opcode;
    logic [31:0] immediate;

    alu_op_t     alu_op;
  } decoded_instr_t;

endpackage

`endif