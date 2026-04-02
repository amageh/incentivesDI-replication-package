import pandas as pd
import numpy as np
import warnings
warnings.filterwarnings('ignore')

def extract_covariates_table(input_csv_path: str, output_tex_path: str ) -> pd.DataFrame:
    # Read in data.
    df = pd.read_csv(input_csv_path)

    # Assign signficance level.
    df["sig"] = np.where(df["pvalue"] < 0.05, 1, 0)
    sig = df.groupby("name")[["sig"]].mean().round(2)
    sig = (sig * 100).astype(int)

    # Get estimate at optimal bandwidth (saved in row 18)
    tab = df[df.row == 18][["coef", "se", "pvalue", "controlmean", "bw", "name"]]
    tab["coef"] = tab["coef"].round(3)
    tab["se"] = tab["se"].round(3)
    tab["controlmean"] = tab["controlmean"].round(2)
    tab["bw"] = tab["bw"].round(2)

    # Add stars for significance.
    tab["coef"] = np.where(tab["pvalue"] < 0.05, tab["coef"].astype(str) + "*", tab["coef"].astype(str))
    tab["coef"] = np.where(tab["pvalue"] < 0.01, tab["coef"].astype(str) + "*", tab["coef"].astype(str))
    tab["coef"] = np.where(tab["pvalue"] < 0.001, tab["coef"].astype(str) + "*", tab["coef"].astype(str))

    # Add parentheses around standard errors and brackets around bandwidths.
    tab["se"] = np.where(True, "(" + tab["se"].astype(str) + ")", np.nan)
    tab["bw"] = np.where(True, "[" + tab["bw"].astype(str) + "]", np.nan)

    # Replace variable names with labels.
    tab["label"] = tab["name"].map({
        "AE_exact_RTZN": "Age",
        "female_RTZN": "Female",
        "teilhabe_prev5y": "Labor market rehabilitation",
        "reha_prev5y": "Medical rehabilitation",
        "diag_1": "Mental diagnosis",
        "diag_2": "Circulatory diagnosis",
        "diag_3": "Neoplasm/Cancers",
        "diag_4": "Musculoskeletal diagnosis",
        "diag_5": "Nervous system",
        "diag_6": "Other diagnosis",
        "occ_service": "Service occupation",
        "occ_manufact": "Manufacturing occupation",
        "occ_technic": "Technical occupation",
        "occ_other": "Other occupation",
        "AZ_UEMP": "Time unemployed",
        "AZ_SICK": "Time sick",
        "AZ_SCHOOL": "Time school",
        "AZ_FULL_CONTRIB": "Full contribution times",
        "AZ_REDUC_CONTRIB": "Reduced contribution times",
        "no_check_LM": "No consideration of employability",
        "UDAQ_RTZN": "DI from rehabilitation application",
        "RTBT_sim_counterfact": "DI benefits w/o reform bonus",
        "RTBT_2014": "DI benefits",
        "RTBT_sim": "Simulated DI benefits",
    })

    # Merge with significance table and reorder.
    tab = tab.merge(sig, on="name")
    tab = tab.set_index("name")
    new_order = [
        'AE_exact_RTZN', "female_RTZN", 'married', 'OPXAZ_RTZN',
        'diag_1', 'diag_2', 'diag_3', 'diag_4', 'diag_5', 'diag_6', 'female_RTZN', 'has_kids_RTZN',
        'AZ_UEMP', 'AZ_SICK',
        'AZ_SCHOOL', 'AZ_FULL_CONTRIB', 'AZ_REDUC_CONTRIB',
        'occ_service', 'occ_manufact', 'occ_technic',
        'occ_other',
        'RTBT_sim_counterfact',
        'teilhabe_prev5y',
        'reha_prev5y',
        'UDAQ_RTZN', 'no_check_LM',
        'RTBT_2014',
        'RTBT_sim',
    ]
    # Reorder and filter to covariates of interest.
    tab = tab.reindex(new_order, axis=0)
    tab = tab.reset_index().set_index("label")
    tab = tab[tab.name.isin([
        'AE_exact_RTZN', "female_RTZN", 
        'diag_1', 'diag_2', 'diag_3', 'diag_4', 'diag_5', 'diag_6',
        'AZ_FULL_CONTRIB', 'AZ_REDUC_CONTRIB',
        'occ_service', 'occ_manufact', 'occ_technic',
        'occ_other',
        'RTBT_sim_counterfact',
        'teilhabe_prev5y',
        'reha_prev5y',
        'UDAQ_RTZN',
        'no_check_LM',
        "RTBT_2014",
    ])]

    # Select relevant columns and format for LaTeX output.
    tab = tab[["coef", "se", "controlmean", "bw", "sig"]]
    tab["empty"] = ""

    # Stack estimates, standard errors, control means and bandwidths into a single table.
    table1 = tab[["coef", "se"]].stack()
    table2 = tab[["controlmean", "bw"]].stack()
    table2.index = table1.index
    table3 = tab[["sig", "empty"]].stack()
    table3.index = table1.index

    out = pd.concat([table1, table2, table3], axis=1)
    out.index = out.index.droplevel(1)
    out.columns = ["Estimates (SE)", "Control mean [BW]", "Percent of bandwidths w/ (p<0.05)"]

    # Add empty rows for better readability.
    label_list = list(out.index)
    for i in list(range(1, len(label_list), 2)):
        label_list[i] = ""
    out.index = pd.Index(label_list)

    out.to_latex(output_tex_path, escape=False, column_format="lccc", index=True)
    return out