module fifo #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 8,
    parameter int PTR_W = $clog2(DEPTH)
) (
    input  logic             clk,
    input  logic             rst_n,

    input  logic             push,
    input  logic [WIDTH-1:0] din,

    input  logic             pop,

    output logic [WIDTH-1:0] dout,
    output logic             full,
    output logic             empty
);

  logic [WIDTH-1:0] mem [0:DEPTH-1];

  logic [PTR_W-1:0] rd_ptr;
  logic [PTR_W-1:0] wr_ptr;
  logic [PTR_W:0]   count;

  assign full  = (count == DEPTH);
  assign empty = (count == 0);
  assign dout  = mem[rd_ptr];

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      rd_ptr <= '0;
      wr_ptr <= '0;
      count  <= '0;
    end else begin

      if (push && !full) begin
        mem[wr_ptr] <= din;
        wr_ptr <= wr_ptr + 1'b1;
      end

      if (pop && !empty)
        rd_ptr <= rd_ptr + 1'b1;

      case ({push && !full, pop && !empty})
        2'b10: count <= count + 1'b1;
        2'b01: count <= count - 1'b1;
        default: count <= count;
      endcase

    end
  end

endmodule