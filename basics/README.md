## Using Genus

```
genus
set DESIGN add_ff
source syn_genus.tcl
```

## If there is a license error, restart the license server using following shell commands:

```
pkill lmgrd
nohup /home/aed/cadence/License/lmgrd /home/aed/cadence/License/License_80452_c4346b56cdb4_11_13_2018.txt
export CDS_LIC_FILE=5281@aed
```
