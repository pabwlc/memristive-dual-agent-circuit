# Dual-Agent Memristive Neuromorphic Circuit

This repository provides hardware and FPGA implementation files for the hybrid analog--FPGA prototype associated with the paper:

**A Dual-Agent Memristive Neuromorphic Circuit for Imitation Learning and Inequity-Related Modulation**

The repository is intended to facilitate inspection and reproduction of the analog signal-processing board and FPGA-based state-transition logic used in the prototype.

## Repository Contents

| File / folder                                       | Description                                                                                                        |
| --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `analog_signal_processing_board.epro2`              | EasyEDA project file of the analog signal-processing board.                                                        |
| `analog_signal_processing_board.zip`                | Archived EasyEDA project file for backup and reproduction.                                                         |
| `analog_signal_processing_board_schematic.pdf`      | Exported schematic of the analog signal-processing board.                                                          |
| `analog_signal_processing_board_pcb_layout_bom.pdf` | Exported PCB layout, component placement, and bill-of-materials information of the analog signal-processing board. |
| `rtl/`                                              | RTL source files for the FPGA-based state-transition logic.                                                        |
| `synapse.qpf`                                       | Quartus project file.                                                                                              |
| `synapse.qsf`                                       | Quartus settings and pin-assignment file.                                                                          |
| `synapse.sdc`                                       | Timing-constraint file used by the Quartus project.                                                                |

## Hardware Description

The analog signal-processing board provides analog signal conditioning, comparison, and interface functions for the hybrid analog--FPGA prototype.

The FPGA implementation provides digital state-transition control, gating logic, and timing-related behavior used for board-level verification.

In the associated paper, the hybrid analog--FPGA prototype is used to verify event order, state-transition logic, gating relationships, and timing behavior. The prototype complements the PSpice system-level simulations by providing board-level validation of the proposed state-transition mechanism.

## Relationship to the Paper

The PSpice simulations in the paper verify the circuit-level learning, imitation, inhibition/recovery, and reward-comparison-driven modulation mechanisms.

The hybrid analog--FPGA prototype verifies the corresponding event order and state-transition behavior at the board level.

This repository provides implementation details of the analog signal-processing board and FPGA-based control logic that are not fully expanded in the main text.

## Notes

* The EasyEDA files are provided for inspection and reproduction of the analog signal-processing board.
* The RTL and Quartus files are provided for inspection and reproduction of the FPGA-based state-transition logic.
* The PCB/BOM PDF is provided as a readable export for users who do not open the EasyEDA project directly.

## Citation

If you use these files, please cite the associated paper:

**A Dual-Agent Memristive Circuit for Imitation Learning and Inequity-Related Emotion Modulation**
