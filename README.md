# arys-Electronics-Joanna
## Fault Detection FSM (HDL Project)

### Overview

This project implements a Fault Detection Finite State Machine (FSM) in Verilog.
The FSM monitors cell voltage and current (extendable to temperature flags), detects abnormal conditions, and transitions through the following states:

- NORMAL → System operating under safe conditions
- WARNING → Abnormality detected, monitored for persistence
- FAULT → Persistent fault confirmed
- SHUTDOWN → System is shut down until reset

The FSM includes features like debounce/persistence check, fault prioritization, and reset-based recovery.

### Features

- Detects Over-voltage, Over-current, and Under-voltage conditions.
- Warning stage allows transient spikes to clear before declaring a fault.
- Fault persistence check with a cycle counter (debounce). 
- Fault priority ensures once FAULT occurs, system moves to SHUTDOWN. 
- System reset brings FSM back to NORMAL safely.

### Transition Conditions:

- NORMAL → WARNING: Voltage/current/temp out of safe range.
- WARNING → NORMAL: Abnormal condition clears within debounce period.
- WARNING → FAULT: Abnormal condition persists beyond debounce counter.
- FAULT → SHUTDOWN: Fault confirmed.
- SHUTDOWN → NORMAL: Reset (rstn=0).

### Number Representation :
The IEEE 754 single- precision format is what I chose for reperesenting the numbers, so that decimal numbers can also be accurately represented.

### Testbench: 
The testbench (tb_fault_Det.v) applies different scenarios:

- Normal Operation → Safe voltage & current.
- Over-Voltage Spike → Goes to WARNING.
- Over-Current Spike → Detected and flagged.
- Under-Voltage Condition → Triggered.
- Persistent Fault → Transitions WARNING → FAULT → SHUTDOWN.
- Reset Recovery → System returns to NORMAL after reset.

### Simulation
The code was compiled and simulated using the MentorGraphics tool, ModelSim. 
