module bht #(
    parameter int ENTRIES = 64,
    parameter int IDX_W = $clog2(ENTRIES)
) (
    input  logic        clk,
    input  logic        rst_n,

    input  logic [31:0] predict_pc,
    output logic        predict_taken,

    input  logic        update_valid,
    input  logic [31:0] update_pc,
    input  logic        actual_taken
);

  logic [1:0] counters [0:ENTRIES-1];

  wire [IDX_W-1:0] pidx = predict_pc[IDX_W+1:2];
  wire [IDX_W-1:0] uidx = update_pc[IDX_W+1:2];

  integer i;

  assign predict_taken = counters[pidx][1];

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      for (i = 0; i < ENTRIES; i = i + 1)
        counters[i] <= 2'b01;
    end else if (update_valid) begin

      if (actual_taken && counters[uidx] != 2'b11)
        counters[uidx] <= counters[uidx] + 1'b1;

      else if (!actual_taken && counters[uidx] != 2'b00)
        counters[uidx] <= counters[uidx] - 1'b1;

    end
  end

endmodule