module cpu_top (
    input  logic        clk,
    input  logic        rst_n,

    output logic        imem_req,
    output logic [31:0] imem_addr,

    input  logic        imem_valid,
    input  logic [31:0] imem_rdata,

    output logic        halted
);

  logic [31:0] pc_q;
  logic [31:0] instruction_q;
  logic        instruction_valid_q;

  assign imem_req  = rst_n && !halted;
  assign imem_addr = pc_q;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      pc_q                 <= 32'h0000_0000;
      instruction_q        <= 32'b0;
      instruction_valid_q  <= 1'b0;
      halted               <= 1'b0;
    end else begin
      instruction_valid_q <= 1'b0;

      if (imem_req && imem_valid) begin
        instruction_q       <= imem_rdata;
        instruction_valid_q <= 1'b1;
        pc_q                <= pc_q + 32'd4;
      end
    end
  end

endmodule