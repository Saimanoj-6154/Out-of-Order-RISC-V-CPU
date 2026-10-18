module btb #(
    parameter int ENTRIES = 16,
    parameter int IDX_W = $clog2(ENTRIES)
) (
    input  logic        clk,
    input  logic        rst_n,

    input  logic [31:0] pc,
    output logic        hit,
    output logic [31:0] target,

    input  logic        update_valid,
    input  logic [31:0] update_pc,
    input  logic [31:0] update_target
);

  logic [31:0] tags    [0:ENTRIES-1];
  logic [31:0] targets [0:ENTRIES-1];
  logic [ENTRIES-1:0] valid_q;

  wire [IDX_W-1:0] idx  = pc[IDX_W+1:2];
  wire [IDX_W-1:0] uidx = update_pc[IDX_W+1:2];

  integer i;

  always_comb begin
    hit = valid_q[idx] && (tags[idx] == pc);
    target = hit ? targets[idx] : 32'b0;
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      valid_q <= '0;

      for (i = 0; i < ENTRIES; i = i + 1) begin
        tags[i]    <= '0;
        targets[i] <= '0;
      end

    end else if (update_valid) begin
      valid_q[uidx] <= 1'b1;
      tags[uidx]    <= update_pc;
      targets[uidx] <= update_target;
    end
  end

endmodule