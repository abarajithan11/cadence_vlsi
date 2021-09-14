# Using Genus

As we have set the PATHs, you can start genus by typing ```genus``` in the unix shell (konsole), and work with it using its own commands. UNIX commands are shown with ```unix>```, while genus commands are shown with ```genus:root: xx>```.

```
unix> genus
genus:root: xx> set DESIGN add_ff
genus:root: xx> source syn_genus.tcl
```

### If there is a license error, restart the license server using following shell commands:

```
unix> pkill lmgrd
unix> nohup /home/aed/cadence/License/lmgrd /home/aed/cadence/License/License_80452_c4346b56cdb4_11_13_2018.txt
unix> export CDS_LIC_FILE=5281@aed
```

### Genus Flow

HDL Files -> Genus Flow -> Netlist, SDC

1. Set search paths & timing libary
2. Load HDL files
3. Perform Elaboration
4. Apply Constraints
5. Apply optimization settings
6. Synthesize
7. Analyze

If constraints are met, 8. Export Design. Else, Modify RTL source and do from (1), change constraints and do from (4) or modify constraints and do from (5).


### Modes
* wireload
* ple (physical layout estimators) - connect LEF file

### Commands

* read_hdl -mixvlog
* check_dft_rules
* max_output_voltage
* retime