#----------------------------------------
# JasperGold Version Info
# tool      : JasperGold 2018.06
# platform  : Linux 3.10.0-957.21.3.el7.x86_64
# version   : 2018.06p002 64 bits
# build date: 2018.08.27 18:04:53 PDT
#----------------------------------------
# started Wed Nov 09 18:31:11 GMT 2022
# hostname  : ee-mill3.ee.ic.ac.uk
# pid       : 4697
# arguments : '-label' 'session_0' '-console' 'ee-mill3.ee.ic.ac.uk:32818' '-style' 'windows' '-data' 'AQAAADx/////AAAAAAAAA3oBAAAAEABMAE0AUgBFAE0ATwBWAEU=' '-proj' '/home/mp619/nfshome/ELEC70048_HWSW_Verification/Hardware/AHB_peripherals_files/rtl/AHB_GPIO/jgproject/sessionLogs/session_0' '-init' '-hidden' '/home/mp619/nfshome/ELEC70048_HWSW_Verification/Hardware/AHB_peripherals_files/rtl/AHB_GPIO/jgproject/.tmp/.initCmds.tcl' 'AHBGPIO.tcl'

clear -all
analyze -clear
analyze -sv AHBGPIO.sv
elaborate -bbox_mul 64 -top AHBGPIO

# Setup global clocks and resets
clock HCLK
reset -expression !(HRESETn)

# Setup task
task -set <embedded>
set_proofgrid_max_jobs 4
set_proofgrid_max_local_jobs 4

prove -bg -property {<embedded>::AHBGPIO.check_datain}
prove -bg -property {<embedded>::AHBGPIO.check_dataout}
prove -bg -task {<embedded>}
