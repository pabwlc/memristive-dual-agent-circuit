# Dual-Agent Memristive Neuromorphic Circuit

This repository provides hardware implementation files for the hybrid analog--FPGA prototype associated with the paper:

**A Memristive Neuromorphic Circuit for Dual-Agent Imitation Learning and Inequity-Related Emotion Modulation**

The repository is intended to facilitate inspection and reproduction of the board-level analog signal-processing hardware used in the prototype.

## Current Files

| File                                                | Description                                                                                                        |
| --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `analog_signal_processing_board.epro2`              | EasyEDA project file of the analog signal-processing board.                                                        |
| `analog_signal_processing_board.zip`                | Archived EasyEDA project file for backup and reproduction.                                                         |
| `analog_signal_processing_board_schematic.pdf`      | Exported schematic of the analog signal-processing board.                                                          |
| `analog_signal_processing_board_pcb_layout_bom.pdf` | Exported PCB layout, component placement, and bill-of-materials information of the analog signal-processing board. |

## Hardware Description

The uploaded files correspond to the analog signal-processing board used in the hybrid analog--FPGA prototype. The board provides analog signal conditioning, comparison, and interface functions for the FPGA-based state-transition control and verification platform.

In the paper, the hybrid analog--FPGA prototype is used to verify event order, state-transition logic, gating relationships, and timing behavior. It is not intended to reproduce every transistor-level or device-level waveform of the PSpice circuit.

## Relationship to the Paper

The PSpice simulations in the paper verify the circuit-level learning, imitation, inhibition/recovery, and reward-comparison-driven modulation mechanisms. The hardware prototype verifies the corresponding event order and state-transition behavior at the board level.

The files in this repository provide implementation details of the analog signal-processing board that are not fully expanded in the main text.

## Planned Additions

The following files may be added in later updates:

* FPGA project files.
* FPGA timing analysis reports.
* FPGA pin assignment files.
* Logic-analyzer waveform records.
* Board-level power measurement records.
* Hardware platform photographs.
* Interface mapping notes.

## Notes

* The EasyEDA files are provided for inspection and reproduction of the analog signal-processing board.
* The PCB/BOM PDF is provided as a readable export for users who do not open the EasyEDA project directly.
* The board-level power values reported in the paper should be interpreted as prototype-level measurements and should not be directly compared with simulated circuit-level power values reported in prior works.

## Citation

If you use these files, please cite the associated paper:

**A Memristive Neuromorphic Circuit for Dual-Agent Imitation Learning and Inequity-Related Emotion Modulation**
