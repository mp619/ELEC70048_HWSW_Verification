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

