#----------------------------------------
# JasperGold Version Info
# tool      : JasperGold 2018.06
# platform  : Linux 3.10.0-957.21.3.el7.x86_64
# version   : 2018.06p002 64 bits
# build date: 2018.08.27 18:04:53 PDT
#----------------------------------------
# started Fri Dec 16 12:58:49 GMT 2022
# hostname  : ee-mill3.ee.ic.ac.uk
# pid       : 100161
# arguments : '-label' 'session_0' '-console' 'ee-mill3.ee.ic.ac.uk:42756' '-style' 'windows' '-data' 'AQAAADx/////AAAAAAAAA3oBAAAAEABMAE0AUgBFAE0ATwBWAEU=' '-proj' '/home/mp619/nfshome/ELEC70048_HWSW_Verification/Hardware/AHB_peripherals_files/rtl/AHB_VGA/jgproject/sessionLogs/session_0' '-init' '-hidden' '/home/mp619/nfshome/ELEC70048_HWSW_Verification/Hardware/AHB_peripherals_files/rtl/AHB_VGA/jgproject/.tmp/.initCmds.tcl' 'AHBVGA.tcl'
clear -all
analyze -clear
analyze -sv -f ahbvga_form.vc
elaborate -bbox_m test -top AHBVGADLS

# Setup global clocks and resets
clock HCLK
reset -expression !(HRESETn)

# Setup task
task -set <embedded>
set_proofgrid_max_jobs 4
set_proofgrid_max_local_jobs 4

prove -bg -property {<embedded>::AHBVGADLS.check_vsync_pulse}
prove -bg -property {<embedded>::AHBVGADLS.check_vsync_pulse:precondition1}
prove -bg -property {<embedded>::AHBVGADLS.check_dls}
prove -bg -property {<embedded>::AHBVGADLS.check_dls:precondition1}
