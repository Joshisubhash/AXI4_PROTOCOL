# Advanced AXI4 Memory-Mapped Slave RTL

An advanced parameterized **AXI4 Memory-Mapped Slave** implemented in **SystemVerilog** featuring independent read and write architectures. The design supports multiple outstanding read transactions, configurable burst transfers, dual-bank memory architecture, response buffering, and out-of-order read responses. The RTL is verified using **UVM** with constrained-random testing and AXI protocol assertions.

---

## Key Features

### Write Architecture
- Independent Write Address (AW) and Write Data (W) FIFOs
- Dedicated write control FSM
- Burst write support:
  - FIXED
  - INCR
  - WRAP
- Write response generation (B Channel)
- Address alignment checking
- 4KB boundary checking
- Error response generation (SLVERR / DECERR)

### Read Architecture
- Independent Read Address (AR) request queue
- Slot-based outstanding transaction engine
- Configurable number of outstanding read slots
- Per-slot read finite state machines
- Dual-bank memory architecture
- Bank arbitration for simultaneous read requests
- Per-slot response buffers
- Round-robin R-channel arbitration
- Out-of-order read response support
- Backpressure handling using VALID/READY handshaking

---

## Supported AXI4 Features

- AXI4 Memory-Mapped Protocol
- Independent Read and Write Channels
- Transaction ID Support
- Multiple Outstanding Read Transactions
- FIXED, INCR and WRAP Bursts
- Configurable Burst Length
- Address Alignment Verification
- 4KB Boundary Protection
- Error Response Generation
- Backpressure Support
- Out-of-Order Read Responses

---

## RTL Architecture

```
                   AXI Master
                       │
        ┌──────────────┴──────────────┐
        │                             │
   Write Architecture            Read Architecture
        │                             │
   AW FIFO + W FIFO              AR Request Queue
        │                             │
    Write FSM               Outstanding Slot Engine
        │                  ┌───────────────┐
        │                  │ Slot 0  Slot1 │
        │                  └───────────────┘
        │                             │
        │                     Bank Arbiter
        │                             │
        │                    RAM0     RAM1
        │                             │
        │                   Response Buffers
        │                             │
        │                   Round Robin Arbiter
        │                             │
     B Channel                    R Channel
```

---

## Project Structure

```
rtl/
├── axi_slave_top.sv
├── write_fsm.sv
├── read_fsm.sv
├── aw_fifo.sv
├── ar_fifo.sv
├── dp_ram.sv

tb/
├── axi_interface.sv
├── axi_driver.sv
├── axi_monitor.sv
├── axi_agent.sv
├── axi_scoreboard.sv
├── axi_environment.sv
├── axi_test.sv
├── sequences/
```

---

## Verification

The design is verified using **UVM** with constrained-random and directed test scenarios.

### Functional Verification

- Single Read/Write
- FIXED Burst
- INCR Burst
- WRAP Burst
- Multiple Outstanding Reads
- Out-of-Order Read Responses
- Backpressure Scenarios
- Address Alignment Checks
- 4KB Boundary Violations
- Error Response Verification
- Dual-Bank Memory Access
- Simultaneous Read Transactions

---

## Technologies Used

- SystemVerilog
- UVM
- Cadence Xcelium
- AXI4 Protocol
- Constrained Random Verification
- SystemVerilog Assertions (SVA)

---

## Future Enhancements

- Configurable arbitration policies
- ECC support
- Timeout handling
- Performance counters
- Coverage-driven regression automation
- Support for higher outstanding transaction counts

---

## Author

**Subhash Joshi**
