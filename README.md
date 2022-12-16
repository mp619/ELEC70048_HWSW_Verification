# ELEC70048_HWSW_Verification

This is the AHB_Peripheral part of Hardware and Software Verification with a focus on Formal and Functional testing using SystemVerilog compiled via Questa Sim-64 Version 10.7c.   

## Structure

```bash
.
└───Hardware                        # Hardware top directory
    └───AHB_peripherals_files       # AHB_Files
        ├───code_coverage           # Code Coverage Files
        ├───docs                    # Documents
        ├───filesdo                 # Do files
        ├───filesVC                 # VC files
        ├───hex                     # Hex Code
        ├───Logs                    # Logs
        ├───outputs                 # Testbench Outputs
        ├───rtl                     # RTL
        │   ├───AHB_GPIO            # AHB_GPIO
        │   └───AHB_VGA             # AHB_VGA
        ├───src                     # Source Files   
        ├───tbench                  # Top level Testbench
        ├───tbench_gpio             # GPIO Testbench
        ├───tbench_vga              # VGA Testbench
        └───work                    # QuantaSim Work Folder
```
## Prerequisites
- Questa Core Prime 10.7c
- JasperGold 2018

## Setup
- SSH into your respective college unix server (ssh –X your-college-name@ee-mill3.ee.ic.ac.uk)
- Copy/Clone git repository to personal directory
- #### Functional Verificaiton
    - Run ```source /usr/local/mentor/QUESTA-CORE-PRIME_10.7c/settings.sh ```
    - Navigate to */Hardware/AHB_peripherals_files*
    - Run ```make testbench_[?]_nogui ``` where [?] = gpio or vga
    - For VGA, an output display file under */Hardware/AHB_peripherals_files/outputs/out_vga.txt* can be found
    - All proceeding log files can be found in */Hardware/AHB_peripherals_files/logs*
    - All Errors will be deisplayed in the command line with a converage report
- #### Formal Verification
    - Run ``` source /usr/local/cadence/JASPER_2018.06.002/settings.sh ```
    - Navigate to */Hardware/AHB_peripherals_files/rtl/[?]* where [?] = AHB_GPIO or AHB_VGA
    - Run ``` make testbench_jg ``` to open JasperGold and complete assertions
    - To check assertions, right click on *Assert* and click on *Prove Task*
- #### Top-Level Integration 
    - Run ```source /usr/local/mentor/QUESTA-CORE-PRIME_10.7c/settings.sh ```
    - Navigate to */Hardware/AHB_peripherals_files*
    - Run ```make testbench_top ``` where [?] = gpio or vga
    - In QuestaSim Transcript insert ``` do ./filesdo/setuptop.do ```   


## Additonal Information

Please see [Verification Plan](./Hardware/AHB_peripherals_files/docs/Verification_Plan.md) for further information about testbench structure

Please see [Verification Report ](./Hardware/AHB_peripherals_files/docs/Verification_Report.md) for information about bugs found, fixes made and top level integration waveforms

Please see [Code Coverage](./Hardware/AHB_peripherals_files/code_coverage) for report full html reports for Code coverage in GPIO and VGA. 
