# Temporal Trinary Logic (00)
**Hardware-Enforced Irreversibility for Sparse Computing and Branch Pruning**


**Author:** Peter Hunt (Independent Researcher, United Kingdom)  
**Version:** 2.4  
**Archival Record (Zenodo):** https://doi.org/10.5281/zenodo.24398575
**Interactive Verilog RTL Simulation (EDA Playground):** https://edaplayground.com/x/TV2X

---

## Overview
**Temporal Trinary Logic (00)** introduces a hardware-enforced absorbing state (*T-Lock / Never*) designed to prune dead or unviable computation branches permanently at the silicon level.

Unlike standard binary logic or traditional three-valued logic systems—where unknown states (`X` or `⊥`) can be overwritten on subsequent clock cycles—Temporal Trinary Logic enforces strict time-dependent irreversibility: once a dual-rail `[Alive, Active]` node enters the **`00` (Terminated)** state, it latches permanently until a global domain reset, immediately severing downstream clock distribution and operand switching.

---

## Repository Contents
* **[Temporal_Trinary_Logic_v2_4.pdf](./Temporal_Trinary_Logic_v2_4.pdf)** — Primary technical specification, formal state-transition rules, dual-rail T-Lock architecture, and power-gating analysis.
* **[Temporal_Trinary_Sim_v2_4.pdf](./Temporal_Trinary_Sim_v2_4.pdf)** — Complete cycle-accurate Python verification source code and benchmark results across three workloads:
  * **Test A:** Sparse Tree Traversal (branch pruning)
  * **Test B:** Streaming Packet Filtering (pipeline gating)
  * **Test C:** MAC Operand Gating (dynamic switching reduction)

---

## Live Hardware RTL Simulation
You can inspect and run the synthesizable Verilog RTL core (`t_lock_core`) and testbench directly in your browser without installing any tools:
* **Run on EDA Playground:** https://edaplayground.com/x/TV2X

---

## Citation & License
This work is licensed under a [Creative Commons Attribution 4.0 International License (CC BY 4.0)](https://creativecommons.org).

> Hunt, P. (2026). *Temporal Trinary Logic (00): Hardware-Enforced Irreversibility for Sparse Computing and Branch Pruning* (v2.4). Zenodo. https://doi.org/10.5281/zenodo.24398575

