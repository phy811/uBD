# uBD-Experiments
Implementation of utility-optimized block design scheme (uBD) in the paper "Optimal Discrete Distribution Estimation under Utillity-Optimized Local Differential Privacy"
## Instructions
Experiments reported in the paper can be reproduced by running the 'Main.m' or 'Main2.mlx'
### Data
- Data used for the experiment is generated through 'preprocessData.m' and the raw data are availiable at https://www.census.gov/programs-surveys/acs/microdata.html
- MSE for each schemes ('MSE_and_R50000_m20.mat' and 'MSE_or_R50000_m20.mat') are generated through the function 'Save_MSE_ULDP.m'
### ULDP schemes
- Encoder and decoder for 5 ULDP schemes are provided: uRR, uRAP, uOUE, uHR, and uBD
- The functions 'encode_opt_ULDP.m' & 'decode_opt_ULDP.m' provide the uBD scheme presented in the paper
### Notes
For successful code execution, make sure to configure the directory paths appropriately within each function
#### Environment Setup
- MATLAB R2024a
- Required Toolboxes: Optimization Toolbox, Symbolic Math Toolbox
## References
