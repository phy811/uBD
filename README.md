# uBD
Implementation of utility-optimized block design scheme (uBD) in the paper "Fundamental Limit of Discrete Distribution Estimation under Utility-Optimized Local Differential Privacy"
## Instructions
Experiments reported in the paper can be reproduced by running the 'Main.m'
### Real World Data
- Data used for the experiment is generated through 'preprocessData.m' and the raw data are availiable at https://www.census.gov/programs-surveys/acs/microdata.html
- The MSE results for each scheme (MSE_and_R50000_m20_nPts50.mat and MSE_or_R50000_m20_nPts50.mat) were generated using the function 'Save_MSE_Real.m'.
- Fig. 6 in the paper can be reproduced by running 'Main_MSE_Real.m'.
- The MSE data for all schemes across different sample sizes (MSE_vsN_and_eps1_m20.mat, MSE_vsN_and_eps5_m20.mat, MSE_vsN_and_eps8_m20.mat, MSE_vsN_or_eps1_m20.mat, MSE_vsN_or_eps5.3_m20.mat, MSE_vsN_or_eps8_m20.mat) were generated using 'Save_MSE_Real_sweep_n.m'.
- Figs. 10 and 11 in the paper can be reproduced by running 'Main_Real_sweep_n.m'.
### Synthetic Data
- Data used for the experiment (Synt_w=300_n=300000_geo.mat and Synt_w=300_n=300000_zipf.mat) is generated through 'Generate_Synt_Data.m'.
- The MSE results for each scheme (MSE_Synthetic_geo_R30000_m20_nPts50.mat and MSE_Synthetic_zipf_R30000_m20_nPts50.mat) were generated using the function 'Save_MSE_Synt.m'.
- Fig. 7 in the paper can be reproduced by running 'Main_MSE_Synt.m'.
- The MSE data for all schemes across different sensitive set sizes (MSE_Synthetic_vsV_geo_w=300_m=20_R=30000_eps=1, MSE_Synthetic_vsV_geo_w=300_m=20_R=30000_eps=6, MSE_Synthetic_vsV_zipf_w=300_m=20_R=30000_eps=1, MSE_Synthetic_vsV_zipf_w=300_m=20_R=30000_eps=6) were generated using 'Save_MSE_Synt_sweep_v.m'.
- Figs. 12 and 13 in the paper can be reproduced by running 'Main_Synt_sweep_v.m'.
### ULDP schemes
- Encoder and decoder for 6 ULDP schemes are provided: uRR, uRAP, uOUE, uHR, uSS, and uBD
- The functions 'encode_opt_ULDP.m' & 'decode_opt_ULDP.m' provide the uBD scheme presented in the paper
### Notes
For successful code execution, make sure to configure the directory paths appropriately within each function
#### Environment Setup
- MATLAB R2024a
- Required Toolboxes: Optimization Toolbox, Symbolic Math Toolbox
## Paper Link
https://arxiv.org/abs/2509.24173
