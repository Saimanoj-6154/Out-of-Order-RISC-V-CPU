module reservation_station #(
    parameter int DEPTH = 8,
    parameter int TAG_W = 4
) (
    input  logic             clk,
    input  logic             rst_n,

    input  logic             dispatch_valid,
    output logic             dispatch_ready,
    input  logic [TAG_W-1:0] dispatch_tag,

    input  logic [31:0]      dispatch_a,
    input  logic [31:0]      dispatch_b,
    input  logic             dispatch_a_ready,
    input  logic             dispatch_b_ready,
    input  logic [TAG_W-1:0] dispatch_a_tag,
    input  logic [TAG_W-1:0] dispatch_b_tag,

    input  logic             cdb_valid,
    input  logic [TAG_W-1:0] cdb_tag,
    input  logic [31:0]      cdb_value,

    output logic             issue_valid,
    input  logic             issue_ready,
    output logic [TAG_W-1:0] issue_tag,
    output logic [31:0]      issue_a,
    output logic [31:0]      issue_b
);

  logic [DEPTH-1:0] valid_q;
  logic [DEPTH-1:0] ready_a_q;
  logic [DEPTH-1:0] ready_b_q;

  logic [TAG_W-1:0] tag_q   [0:DEPTH-1];
  logic [TAG_W-1:0] a_tag_q [0:DEPTH-1];
  logic [TAG_W-1:0] b_tag_q [0:DEPTH-1];

  logic [31:0] a_q [0:DEPTH-1];
  logic [31:0] b_q [0:DEPTH-1];

  integer i;
  integer free_idx;
  integer issue_idx;

  always_comb begin
    free_idx  = -1;
    issue_idx = -1;

    for (int j = 0; j < DEPTH; j++) begin
      if (!valid_q[j] && free_idx == -1)
        free_idx = j;

      if (valid_q[j] &&
          ready_a_q[j] &&
          ready_b_q[j] &&
          issue_idx == -1)
        issue_idx = j;
    end

    dispatch_ready = (free_idx != -1);
    issue_valid    = (issue_idx != -1);

    issue_tag = (issue_idx == -1) ? '0 :
                tag_q[issue_idx];

    issue_a = (issue_idx == -1) ? '0 :
              a_q[issue_idx];

    issue_b = (issue_idx == -1) ? '0 :
              b_q[issue_idx];
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      valid_q   <= '0;
      ready_a_q <= '0;
      ready_b_q <= '0;

      for (i = 0; i < DEPTH; i = i + 1) begin
        tag_q[i]   <= '0;
        a_tag_q[i] <= '0;
        b_tag_q[i] <= '0;
        a_q[i]     <= '0;
        b_q[i]     <= '0;
      end

    end else begin

      if (dispatch_valid && dispatch_ready) begin
        valid_q[free_idx]   <= 1'b1;
        tag_q[free_idx]     <= dispatch_tag;
        a_q[free_idx]       <= dispatch_a;
        b_q[free_idx]       <= dispatch_b;
        ready_a_q[free_idx] <= dispatch_a_ready;
        ready_b_q[free_idx] <= dispatch_b_ready;
        a_tag_q[free_idx]   <= dispatch_a_tag;
        b_tag_q[free_idx]   <= dispatch_b_tag;
      end

      if (cdb_valid) begin
        for (i = 0; i < DEPTH; i = i + 1) begin

          if (valid_q[i] &&
              !ready_a_q[i] &&
              a_tag_q[i] == cdb_tag) begin
            a_q[i]       <= cdb_value;
            ready_a_q[i] <= 1'b1;
          end

          if (valid_q[i] &&
              !ready_b_q[i] &&
              b_tag_q[i] == cdb_tag) begin
            b_q[i]       <= cdb_value;
            ready_b_q[i] <= 1'b1;
          end

        end
      end

      if (issue_valid && issue_ready)
        valid_q[issue_idx] <= 1'b0;

    end
  end

endmodule