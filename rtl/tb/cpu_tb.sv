`timescale 1ns/1ps

module cpu_tb;

  logic clk = 1'b0;
  logic rst_n = 1'b0;

  logic imem_req;
  logic [31:0] imem_addr;
  logic imem_valid;
  logic [31:0] imem_rdata;
  logic halted;

  always #5 clk = ~clk;

  cpu_top dut (
    .clk(clk),
    .rst_n(rst_n),
    .imem_req(imem_req),
    .imem_addr(imem_addr),
    .imem_valid(imem_valid),
    .imem_rdata(imem_rdata),
    .halted(halted)
  );

  initial begin
    imem_valid = 1'b0;
    imem_rdata = 32'h0000_0013; // ADDI x0, x0, 0

    repeat (3) @(posedge clk);
    rst_n = 1'b1;

    repeat (2) @(posedge clk);

    @(negedge clk);
    imem_valid = 1'b1;

    repeat (8) @(posedge clk);

    $display(
      "Smoke test completed. PC = 0x%08h",
      imem_addr
    );

    $finish;
  end

endmodule