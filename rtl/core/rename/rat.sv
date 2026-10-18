module rat (
    input  logic       clk,
    input  logic       rst_n,

    input  logic [4:0] arch_rs1,
    input  logic [4:0] arch_rs2,
    input  logic [4:0] arch_rd,

    input  logic       rename_en,
    input  logic       writes_rd,
    input  logic [5:0] new_phys,

    output logic [5:0] phys_rs1,
    output logic [5:0] phys_rs2,
    output logic [5:0] old_phys_rd
);

  logic [5:0] map_table [0:31];
  integer i;

  always_comb begin
    phys_rs1    = (arch_rs1 == 0) ? 6'd0 :
                  map_table[arch_rs1];

    phys_rs2    = (arch_rs2 == 0) ? 6'd0 :
                  map_table[arch_rs2];

    old_phys_rd = (arch_rd == 0) ? 6'd0 :
                  map_table[arch_rd];
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      for (i = 0; i < 32; i = i + 1)
        map_table[i] <= i[5:0];
    end else if (rename_en && writes_rd && arch_rd != 0) begin
      map_table[arch_rd] <= new_phys;
    end
  end

endmodule