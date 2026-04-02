"""Functions to plot heterogeneity graphs."""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


def coefplot(data, outcome, tick_size=12, label_size=20, xlim=None, relative=False, appendix=False):
    """
    Create a coefficient plot with confidence intervals.

    Parameters:
    data (pd.DataFrame): DataFrame containing the coefficients, standard errors, control means and labels for the plot.
    outcome (str): Name of the outcome variable (used for saving the plot).
    tick_size (int): Font size for the tick labels.
    label_size (int): Font size for the axis labels and plot title.
    xlim (tuple): Limits for the x-axis (min, max). If None,
        the limits will be set automatically based on the data.
    relative (bool): If True, coefficients and standard errors will be plotted relative to the control mean.
    appendix (bool): If True, the plot will be saved with a prefix "appendix_" in the filename.

    Returns:
    None: The function saves the plot as an EPS file and does not return anything.
    """
    # Get data for plot.
    if relative:
        coefficients = np.flip(data["Coefficent"].to_numpy())/np.flip(data["ControlMean"].to_numpy())
        std_errors = np.flip(data["StandardError"].to_numpy())/np.flip(data["ControlMean"].to_numpy())
    else:
        coefficients = np.flip(data["Coefficent"].to_numpy())
        std_errors = np.flip(data["StandardError"].to_numpy())
        
    labels = np.flip(data["label"])
             

    _, ax = plt.subplots(figsize=(11, 10))
    plt.errorbar(coefficients, np.arange(len(coefficients)), xerr=std_errors * 1.96, fmt='o', capsize=5.0, color="black", alpha=0.8, markeredgecolor="k", markersize=10)
    ax.axvline(x=0, color='red', linestyle='--')
    ax.set_yticks(np.arange(len(coefficients)))
    ax.set_yticklabels(labels=labels, fontdict={"fontsize":label_size})  
    ax.set_xlabel('Coefficient Value', fontsize=label_size) 
    ax.grid(True, axis='x', linestyle='--', linewidth=0.5)
    ax.grid(True, axis='y', linestyle='--', linewidth=0.5)


    if xlim is not None:
        ax.set_xlim(xlim)
        ax.set_xticks(np.arange(xlim[0],xlim[1] + xlim[1]*0.1,(xlim[1]/2)))
        
    ax.tick_params(axis='both', which='major', labelsize=tick_size)  # Increase tick size   
    for v in 4,10,17,20,24:
        ax.hlines(v, xmin=xlim[0], xmax=xlim[1],color="white")
    
    # Set top and right axis lines to lightgray
    ax.spines['top'].set_color('lightgray')
    ax.spines['right'].set_color('lightgray')

    plt.yticks(fontsize=22)       
    plt.tight_layout()

    if appendix:
        prfx = "appendix_"
    else:
        prfx = ""

    if relative:
        plt.savefig(f"../out/{prfx}rdd-heterogeneity-{outcome}-relative.eps", dpi=300, bbox_inches="tight", format='eps')
        #plt.savefig(f"../out/{prfx}rdd-heterogeneity-{outcome}-relative.png", dpi=300, bbox_inches="tight", format='png')
    else:
        plt.savefig(f"../out/{prfx}rdd-heterogeneity-{outcome}.eps", dpi=300, bbox_inches="tight", format='eps')
        #plt.savefig(f"../out/{prfx}rdd-heterogeneity-{outcome}.png", dpi=300, bbox_inches="tight", format='png')



def func_select_outcome_df(outcome: str, results_csv: str):
    """Select the relevant rows from the results csv for a given outcome and add labels for the plot."""
    out = pd.read_csv(rf"../data/{results_csv}")
    
    out = out[out["Variable"] == outcome]
    out = out.reset_index()
    empties = np.empty([5,8],dtype=str)
    empties[:] = " "
    out = pd.concat([out, pd.DataFrame(empties, index=list(range(10001,10006)))], axis=1)
    out["id"] = [1,3,4,5,7,8,10,11,12,13,14,15,17,18,19,20,21,23,24,25,26,2,6,9,16,22]
    out = out.sort_values(by="id")
    out["label"] = [
        "All", " ", "Age below 40", "Age 40-50", "Age 50-60", " ","Female", "Male"," ", 
        "Mental", "Circulatory", "Neoplasm/Cancer", "Musculoskeletal", "Nervous","Other"," ",
        "Quintile 1", "Quintile 2", "Quintile 3", "Quintile 4", "Quintile 5"," ", 
        "Service", "Manufacturing", "Technical", "Other"
                    ]
    return out[["Coefficent", "StandardError", "ControlMean","label", "id"]].reindex()

