# Digital IC Design Flow

Frontend DICD flow consists of the following 6 steps. After completing them, we can send the resulting files to a fabrication plant, where they use the files to physically make the IC on silicon, through their backend process. 

1. RTL Design
2. Synthesis
3. DFT Insertion
4. IO & Floorplan
5. Place & Route
6. Layout Verification

## RTL Design

You first design your digital circuit and then express it by writing RTL (Register Transfer Level) Verilog / SystemVerilog / VHDL code. You will use the advanced RTL coding practices of ASIC design such as asynchronous reset, avoiding nested muxes, avoiding unintended latches...etc. Hierarchical design is good practice. One module is the top module, it instantiates other modules, which instantiate other and so on. You need to test your RTL design rigorously in randomized simulation (functional verification).

Here, you have been provided an example RTL design of a uart transceiver that can send and receive information via UART interface. You will be getting the experience of using Cadence IC design tools, by taking this deign through the 6 steps, while fixing errors...etc.

## Synthesis

The synthesis tool (Cadence Genus / Synopsis Design Compiler) takes your RTL design (set of verilog files) and returns the netlist (another set of verilog files). The tool deconstructs the logic elements in your code and rebuild your code using standard cells (different types of AND gates, fip flops...etc) that are supported by the fab. For this you also need to provide the technology library, which has been given by your fab. We will be using 32nm library from TSMC (Taiwan Semiconductor Manufacturing Company) provided in the libs folder.