module reorder_buffer #(
    parameter int DEPTH = 16,
    parameter int TAG_W = $clog2(DEPTH)
) (
    input  logic             clk,
    input  logic             rst_n,

    input  logic             alloc_valid,
    output logic             alloc_ready,
    output logic [TAG_W-1:0] alloc_tag,

    input  logic             wb_valid,
    input  logic [TAG_W-1:0] wb_tag,
    input  logic [31:0]      wb_value,
    input  logic [5:0]       wb_phys_rd,

    input  logic             commit_ready,
    output logic             commit_valid,
    output logic [TAG_W-1:0] commit_tag,
    output logic [31:0]      commit_value,
    output logic [5:0]       commit_phys_rd
);

  logic [DEPTH-1:0] valid_q;
  logic [DEPTH-1:0] done_q;

  logic [31:0] value_q [0:DEPTH-1];
  logic [5:0]  phys_q  [0:DEPTH-1];

  logic [TAG_W-1:0] head_q;
  logic [TAG_W-1:0] tail_q;
  logic [TAG_W:0]   count_q;

  integer i;

  assign alloc_ready = (count_q < DEPTH);
  assign alloc_tag   = tail_q;

  assign commit_valid =
      (count_q != 0) &&
      valid_q[head_q] &&
      done_q[head_q];

  assign commit_tag     = head_q;
  assign commit_value   = value_q[head_q];
  assign commit_phys_rd = phys_q[head_q];

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      head_q  <= '0;
      tail_q  <= '0;
      count_q <= '0;
      valid_q <= '0;
      done_q  <= '0;

      for (i = 0; i < DEPTH; i = i + 1) begin
        value_q[i] <= '0;
        phys_q[i]  <= '0;
      end

    end else begin

      if (alloc_valid && alloc_ready) begin
        valid_q[tail_q] <= 1'b1;
        done_q[tail_q]  <= 1'b0;
        value_q[tail_q] <= '0;
        phys_q[tail_q]  <= '0;
        tail_q <= tail_q + 1'b1;
      end

      if (wb_valid && valid_q[wb_tag]) begin
        done_q[wb_tag]  <= 1'b1;
        value_q[wb_tag] <= wb_value;
        phys_q[wb_tag]  <= wb_phys_rd;
      end

      if (commit_valid && commit_ready) begin
        valid_q[head_q] <= 1'b0;
        done_q[head_q]  <= 1'b0;
        head_q <= head_q + 1'b1;
      end

      case ({
        alloc_valid && alloc_ready,
        commit_valid && commit_ready
      })
        2'b10: count_q <= count_q + 1'b1;
        2'b01: count_q <= count_q - 1'b1;
        default: count_q <= count_q;
      endcase

    end
  end

endmodule