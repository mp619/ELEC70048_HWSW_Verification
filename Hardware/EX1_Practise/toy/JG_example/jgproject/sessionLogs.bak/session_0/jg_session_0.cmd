#----------------------------------------
# JasperGold Version Info
# tool      : JasperGold 2018.06
# platform  : Linux 3.10.0-957.21.3.el7.x86_64
# version   : 2018.06p002 64 bits
# build date: 2018.08.27 18:04:53 PDT
#----------------------------------------
# started Wed Nov 09 11:01:05 GMT 2022
# hostname  : ee-mill3.ee.ic.ac.uk
# pid       : 65257
# arguments : '-label' 'session_0' '-console' 'ee-mill3.ee.ic.ac.uk:40731' '-style' 'windows' '-data' 'AQAAADx/////AAAAAAAAA3oBAAAAEABMAE0AUgBFAE0ATwBWAEU=' '-proj' '/home/mp619/nfshome/ELEC70048_HWSW_Verification/Hardware/EX1_Practise/toy/JG_example/jgproject/sessionLogs/session_0' '-init' '-hidden' '/home/mp619/nfshome/ELEC70048_HWSW_Verification/Hardware/EX1_Practise/toy/JG_example/jgproject/.tmp/.initCmds.tcl' 'multiplier.tcl'
# Script for multiplier example in JasperGold
clear -all
analyze -clear
analyze -sv multiplier.sv
elaborate -bbox_mul 64 -top multiplier

# Setup global clocks and resets
clock clk
reset -expression !(rst_n)

# Setup task
task -set <embedded>
set_proofgrid_max_jobs 4
set_proofgrid_max_local_jobs 4

cover -name test_cover_from_tcl {@(posedge clk) disable iff (!rst_n) done && ab == 10'd35}
prove -bg -property {<embedded>::multiplier.check_result}
visualize -violation -property <embedded>::multiplier.check_result -new_window
