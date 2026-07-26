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
