# Out-of-Order-RISC-V-CPU
An Out-of-Order (OoO) RISC-V processor implemented in SystemVerilog, featuring dynamic instruction scheduling, register renaming, speculative execution, branch prediction, and in-order retirement.

This project demonstrates modern superscalar CPU microarchitecture concepts used in commercial processors while maintaining compatibility with the RISC-V ISA.

## Overview

- **ISA**: RV32IM (integer + multiply/divide), extensible to RV32IMAFD
- **Pipeline**: 6-stage — Fetch → Decode/Rename → Dispatch → Issue → Execute → Commit
- **Scheduling**: Reservation stations (Tomasulo algorithm) with dynamic instruction issue
- **Renaming**: Physical register file with Register Alias Table (RAT), configurable depth
- **In-order commit**: Reorder Buffer (ROB) for precise exceptions and speculation recovery
- **Branch prediction**: 2-bit saturating counter (gshare/BHT variant), with misprediction squash
- **Memory**: Load/Store Queue with store-to-load forwarding, in-order memory disambiguation
- **Verification**: UVM testbench, functional coverage, SVA assertions, RISC-V compliance suite
- **Toolflow**: Verilator for fast sim, Yosys/OpenLane for synthesis, GTKWave for waveform debug

## Features

- RV32I ISA
- Five logical pipeline stages
- Out-of-Order execution
- Register Renaming
- Reservation Stations
- Reorder Buffer (ROB)
- Common Data Bus (CDB)
- Tomasulo-style Scheduling
- Dynamic Hazard Resolution
- Branch Prediction
- Speculative Execution
- Load Store Queue
- Exception Handling
- Instruction Cache
- Data Cache
- FPGA Compatible
- Open-source ASIC Flow


## Microarchitecture

```
                   +------------------+
                   | Instruction Cache|
                   +--------+---------+
                            |
                         Fetch Unit
                            |
                  Branch Predictor
                            |
                          Decode
                            |
                    Register Rename
                            |
                    Dispatch Logic
                            |
              +-------------+-------------+
              |                           |
       Reservation Stations        Load Store Queue
              |                           |
      Integer Execution Units      Memory Unit
              |                           |
              +-------------+-------------+
                            |
                     Common Data Bus
                            |
                    Reorder Buffer
                            |
                        Commit Stage
                            |
                     Architectural RF
```
---

Key structures:

| Structure | Purpose |
|---|---|
| RAT (Register Alias Table) | Maps architectural → physical registers |
| Free List | Tracks available physical registers |
| ROB (Reorder Buffer) | Enables in-order commit / precise state |
| Reservation Stations | Per-functional-unit operand buffering & wakeup |
| CDB (Common Data Bus) | Broadcasts results for RS wakeup + ROB writeback |
| LSQ (Load/Store Queue) | Memory ordering, store-to-load forwarding |


## Repo Structure

```
|
├── README.md
├── LICENSE
├── .gitignore
├── Makefile
│
├── docs/
│   ├── architecture.md
│   ├── pipeline.md
│   ├── branch_prediction.md
│   ├── memory_subsystem.md
│   ├── verification_plan.md
│   ├── performance_results.md
│   ├── images/
│   │   ├── cpu_block_diagram.png
│   │   ├── pipeline.png
│   │   ├── reorder_buffer.png
│   │   ├── reservation_station.png
│   │   └── execution_flow.png
│   └── references.md
│
├── rtl/
│   ├── core/
│   │   ├── cpu_top.sv
│   │   ├── frontend/
│   │   │   ├── fetch.sv
│   │   │   ├── branch_predictor.sv
│   │   │   ├── btb.sv
│   │   │   ├── bht.sv
│   │   │   ├── ras.sv
│   │   │   └── icache_if.sv
│   │   │
│   │   ├── decode/
│   │   │   ├── decoder.sv
│   │   │   ├── dispatcher.sv
│   │   │   └── register_rename.sv
│   │   │
│   │   ├── rename/
│   │   │   ├── freelist.sv
│   │   │   ├── rat.sv
│   │   │   └── checkpoint.sv
│   │   │
│   │   ├── issue/
│   │   │   ├── reservation_station.sv
│   │   │   ├── issue_queue.sv
│   │   │   └── wakeup_select.sv
│   │   │
│   │   ├── execute/
│   │   │   ├── alu.sv
│   │   │   ├── multiplier.sv
│   │   │   ├── divider.sv
│   │   │   ├── branch_unit.sv
│   │   │   └── csr_unit.sv
│   │   │
│   │   ├── memory/
│   │   │   ├── load_store_queue.sv
│   │   │   ├── store_buffer.sv
│   │   │   ├── dcache_if.sv
│   │   │   └── memory_controller.sv
│   │   │
│   │   ├── commit/
│   │   │   ├── reorder_buffer.sv
│   │   │   ├── commit_logic.sv
│   │   │   └── exception_handler.sv
│   │   │
│   │   ├── cache/
│   │   │   ├── icache.sv
│   │   │   └── dcache.sv
│   │   │
│   │   └── common/
│   │       ├── fifo.sv
│   │       ├── arbiter.sv
│   │       ├── priority_encoder.sv
│   │       └── definitions.svh
│   │
│   └── tb/
│       ├── cpu_tb.sv
│       ├── memory_model.sv
│       ├── clock_reset.sv
│       └── assertions.sv
│
├── sim/
│   ├── run.sh
│   ├── compile.sh
│   ├── waveform.do
│   └── Makefile
│
├── test/
│   ├── isa_tests/
│   ├── assembly/
│   ├── random_tests/
│   ├── benchmark/
│   └── regression/
│
├── scripts/
│   ├── compile.py
│   ├── run_tests.py
│   ├── generate_reports.py
│   └── lint.sh
│
├── synthesis/
│   ├── yosys/
│   ├── openlane/
│   └── reports/
│
├── fpga/
│   ├── nexys_a7/
│   ├── arty_a7/
│   └── constraints/
│
├── waveforms/
│
├── reports/
│   ├── timing/
│   ├── area/
│   ├── power/
│   └── coverage/
│
└── assets/
    ├── screenshots/
    └── diagrams/
```
---
##  Verification Approach

- **Reference model**: instruction-accurate Python golden model checks
  architectural register/memory state at commit against RTL.
- **Scoreboard**: transaction-level compare at ROB retirement.
- **Functional coverage**: hazard types (RAW/WAW/WAR), RS full/empty,
  branch mispredict + recovery, exception at various pipeline depths,
  full/empty ROB, back-to-back dependent issue.
- **Assertions (SVA)**: structural invariants — ROB never issues out of
  order at commit, RAT entries never point to a freed physical register,
  no two RS entries claim the same physical destination simultaneously.
- **Compliance**: `riscv-arch-test` suite run through the core to check
  base ISA correctness independent of microarchitecture.

