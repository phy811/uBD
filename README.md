# uBD-Experiments
Implementation of utility-optimized block design scheme (uBD) in the paper "Optimal Discrete Distribution Estimation under Utillity-Optimized Local Differential Privacy"
## Instructions
Experiments reported in the papaer can be reproduced by running the 'Main.mlx'.
### Data
Data used for the experiment is generated through 'preprocessData.m' and 'Save_MSE_ULDP.m', the row data are availiable at https://www.census.gov/programs-surveys/acs/microdata.html
### ULDP schemes
Encoder and decoder for 5 ULDP schemes are provided: uRR, uRAP, uOUE, uHR, and uBD.
The functions 'encode_opt_ULDP.m' & 'decode_opt_ULDP.m' provide the uBD schme presented in the paper.
### Notes
For successful code execution, make sure to configure the directory paths appropriately within each function.
#### Environment Setup
- MATLAB R2024a
- Required Toolboxes: Optimization Toolbox, Symbolic Math Toolbox
## References
