# REPLICATION PACKAGE

This repository contains replication code for generating all tables and figures in the
paper "*Incentive Effects of Disability Benefits*" (Annica Gehlen, Sebastian Becker, Johannes Geyer, Peter Haan)

## REQUIREMENTS

Data Analysis

- Stata 18.0
- Required packages: rdrobust
- Data access to the administrative data by the German Pension Insurance (DRV)

Selected Output Graphs and Tables

- Python 3.11 or higher
- Required packages: pandas, numpy, matplotlib

## DATA

Running this replication package requires access to the administrative data and secure remote access environment provided by the research data center of the German Pension Insurance (FDZ-RV).

Information on applying for data access is available here: https://fdz-rv.de/en

The statistics data files used are:

- RTZN 2011-2021
- AKVS 2011-2021
- RTWF 2012-2021

## PREPARE PROJECT DATA

The preparation of the project data has to be done by an *employee of the FDZ-RV* who as access to the master data files provided by the research data center. To prepare the data (and later run the analysis), the folder `fdz-rv-codes/` needs to be copied to the remote access directory at the research data center.

They then need to run the scripts to prepare the relevant data sets:

- `syntax/do-data/00_extract_project_data.do`
- `syntax/do-data/01_extract_full_akvs_data.do`

Running these scripts will require updating the file paths at the top of the file.

The first script adds the data of DI recipients used in the paper to the directory data/. This step first extracts all individuals who started receiving DI benefits between 2011 and 2021 from the RTZN and than extracts employment data from the AKVS and mortality information from the RTWF based on their IDs.

The second script draws a subset of variables from the full AKVS data for the years 2012-2017 which is used in the takeup analysis.

## REPLICATION INSTRUCTIONS

### A. DATA ANALYSIS @ THE FDZ-RV

Part A of this replication packages includes instructions on running the main analysis at the research data center FDZ-RV with their on-site data once the project data has been prepared by an employee of the FDZ-RV.

All analyses use STATA and need to be performed at a research data center or via remote access.

**1. Update file paths & add output and temp folders**

Before running the scripts, update the file paths in the main do files:

- `syntax/do-rdd/00_main.do`
- `syntax/do-takeup/00_main.do`


**2. Run main scripts**

There are two main files to run the full data cleaning and analysis pipeline.

**2.1. Run the RDD analysis on employment, DI exit, and mortality:** (Runtime ca. 8 h)

Run the file `syntax/do-rdd/00_main.do`. The file will perform the following steps and create the following outputs:
  
 **STEP A:** Clean data and create main analysis sample (Runtime 20 mins)

  - **Output files**: dta files saved to `temp/`
  
 **STEP B:** Create descriptive statistics (Runtime 5 mins)

  - **Output files**: Appendix files saved to `out/B_descriptives`
  
 **STEP C:** Run balancing checks (Runtime 45 mins)

  - **Output files**: saved to `out/C_balancing/`
    - Benefit change graph (Figure 5) [*RTBT_2014_by_gender.png*]
    - Density Graph (Figure 7) [*density_plot_rdd_gender.png*]
    - Balancing Table Output (Table 2) [*OUT_RDD_COVARIATES_BW.csv*]
    - Appendix materials
  
 **STEP D:** Run main RDD analysis (Runtime 5-7 h)

  - **Output**: saved to D_RDD_outputs
    - *first_stage*: 
       - Benefit heterogeneity (Figure 6) [*OUT_FIRSTSTAGE_HETEROGENEITY.csv*]
    - *labor_supply*:
       - RDD graphs employment (Figure 9) [*REGEMP_rec_by_gender.png, REGEMP_avg_rec_by_gender.png,
     MEMP_rec_by_gender.png, MEMP_rec_by_gender.png*]
       - Employment outcomes (Table 3) [*OUT_LABOR_CONTROLS.csv*, *OUT_RDD_EMPLOYMENT_BW.csv*]
       - Employment heterogeneity (Figure 10) [*OUT_LABOR_HETEROGENEITY.csv*]
    - *status*: 
       - RDD graph recipient status after 4 years [*status_none_post4_by_gender.png*]
       - Exit heterogeneity (Figure 12) [*OUT_STATUS_HETEROGENEITY.csv*]
       - Exit outcomes annual (Table 4) [*OUT_STATUS_CONTROLS.csv*, *OUT_RDD_STATUS_BW.csv*]
    - *mortality*:
       - RDD graph mortality (Figure 13) [*dead_post_6_by_gender.png*]
       - Mortality heterogeneity (Figure 14) [*OUT_MORTALITY_HETEROGENEITY.csv*]
       - Exit ouctomes annual (Table 5) [*OUT_MORTALITY_CONTROLS.csv*, *OUT_RDD_MORTALITY_BW.csv*]
    - Appendix materials

**2.2. Run the takeup analysis** (Runtime ca. 2h)

Run the file `syntax/do-takeup/00_main.do`. The file will create the following outputs:

 **STEP A**: Clean data and create main analysis sample 

  - **Output files**: dta files saved to temp/
  
 **STEP B**: Run analysis

  - **Output files**: saved to `A_takeup/`
    - Graphs on DI takeup (Figure 4 a&b) [two figures] 
    - Regression results (Table 1) [three .tex files]

Lastly, ask an employee of the FDZ-RV data center to export all results stored in `out/`.

### B. PRODUCING FINAL FIGURES & TABLES (ON OWN MACHINE)

Most of the figures in the paper are produced using Python and are based on .csv data generated by running the codes above at the FDZ-RV. After producing the .csv outputs above, the figures and tables are created using a Python routine.

The codes are stored in the folder `figure-table-codes\src`.

To create the files, the following steps are required (Runtime 30 s):
 
 **STEP A:** Via the terminal install all packages listed in `environment.yml`.

 **STEP B:** Place all .csv files created in 2.2. in the folder `figure-table-codes\data\`.

 **STEP C:** Via the terminal navigate to `src\` and run the code in `src\run.py` to create all figures and tables.
   Outputs will be saved to `out\` . Calculations for the fiscal multiplier are printed at the end of the file
   and additionally saved to a tex file.
 
 ```python run.py```

**Output files**:

 FIGURES:

 - Heterogeneity in benefits (Figure 6) [*rdd-heterogeneity-RTBT_2014.png*]
 - Heterogeneity in earnings (Figure 10) [*rdd-heterogeneity-MEMP_avg_rec.png*, *rdd-heterogeneity-REGEMP_avg_rec.png*]
 - Heterogeneity in exit (Figure 12) [*rdd-heterogeneity-status_pension_post4.png*]
 - Heterogeneity in mortality (Figure 14) [*rdd-heterogeneity-dead_post_6.png*]

 TABLES:

 - Balancing of covariates (Table 2) [*covariates.tex*]
 - Employment outcomes (Table 3) [*employment.tex*]
 - DI exit (Table 4) [*status-annual-pension.tex*]
 - Mortality (Table 5) [*mortality-fraction-dead.tex*]
 - Fiscal Multiplier Calculation (Table 6) [*fiscal_multiplier.tex*]

## DIRECTORY STRUCTURE

```
fdz-rv-codes/
   data/
      _OUT_DATA_WORK/
      AKVS/
      RTWF/
      RTZN/
   out/
      A_takeup/
      B_descriptives/
      C_balancing/
         covariates/
         manipulation/
      D_RDD_outcomes/
         first_stage/
         labor_supply/
         mortality/
         status/
   syntax/
      do_data/
      do-rdd/
      do-takeup/
   temp/
    C_temp/
    D_temp_firststage/
    D_temp_labor/
      with_covariates/
      robustness/
    D_temp_mortality
       with_covariates/
    D_temp_permanent
       with_covariates/
    D_temp_status
       with_covariates/

figure-table-codes/
 data/
 out/
 src/
 ```