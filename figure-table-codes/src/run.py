import matplotlib.pyplot as plt


from extract_covariates_table import extract_covariates_table
from extract_mortality_table import extract_mortality_table
from extract_employment_table import extract_employment_table
from extract_status_table import extract_status_table

# from extract_permanent_table import extract_permanent_table

from plot_heterogeneity_graphs import func_select_outcome_df, coefplot
from compute_fiscal_multiplier import compute_fiscal_multiplier


def run_all():
    """Run all table extraction and graph generation functions."""
    results = {}

    results["covariates"] = extract_covariates_table(
        input_csv_path="../data/OUT_RDD_COVARIATES_BW.csv",
        output_tex_path="../out/covariates.tex",
    )
    results["mortality"] = extract_mortality_table(
        df_path="../data/OUT_MORTALITY_HETEROGENEITY.csv",
        controls_path="../data/OUT_MORTALITY_CONTROLS.csv",
        output_path="../out/mortality-fraction-dead.tex",
    )

    main_emp = [["MEMP_rec", "REGEMP_rec", "REGEMP_avg_rec", "MEMP_avg_rec"]]
    earnings = [
        [
            "REGEMP_earnings_post1",
            "REGEMP_earnings_post2",
            "REGEMP_earnings_post3",
            "REGEMP_earnings_post4",
            "MEMP_earnings_post1",
            "MEMP_earnings_post2",
            "MEMP_earnings_post3",
            "MEMP_earnings_post4",
        ]
    ]
    emp_annual = [
        [
            "REGEMP_post1",
            "REGEMP_post2",
            "REGEMP_post3",
            "REGEMP_post4",
            "REGEMP_post5",
            "MEMP_post1",
            "MEMP_post2",
            "MEMP_post3",
            "MEMP_post4",
            "MEMP_post5",
        ]
    ]

    for outcome_list, label in zip(
        [main_emp, earnings, emp_annual],
        [
            "employment",
            "appendix_employment_earnings_annual",
            "appendix_employment_annual",
        ],
    ):
        results[label] = extract_employment_table(
            df_path="../data/OUT_LABOR_HETEROGENEITY.csv",
            controls_path="../data/OUT_LABOR_CONTROLS.csv",
            output_path=f"../out/{label}.tex",
            outcomes=outcome_list,
        )

    results["status"] = extract_status_table(
        df_path="../data/OUT_STATUS_HETEROGENEITY.csv",
        controls_path="../data/OUT_STATUS_CONTROLS.csv",
        output_path="../out/status-annual-pension.tex",
    )

    # Uncomment to run robustness check for permanent recipients in Appendix.
    # results['permanent'] = extract_permanent_table(
    #    df_path="../data/appendix_OUT_PERMANENT_SAMPLE_CONTROLS0.csv",
    #    controls_path="../data/appendix_OUT_PERMANENT_SAMPLE_CONTROLS1.csv",
    #    output_path="../out/permanent-overall.tex",
    # )

    return results


if __name__ == "__main__":
    results = run_all()
    print("\n\n TABLES .........................................................")
    for name in results.keys():
        print(f"Extracted table for {name} and saved to file.")
        print(results[name])
        print("\n\n ------------------------------------------------------------")

    print("\n \n GRAPHS ......................................................")

    # Benefits/first stage
    for lim, relative in zip([(-200, 200), (-0.2, 0.2)], [False, True]):
        result = func_select_outcome_df(
            outcome="RTBT_2014", results_csv=r"OUT_FIRSTSTAGE_HETEROGENEITY.csv"
        )
        coefplot(
            data=result,
            outcome="RTBT_2014",
            tick_size=20,
            label_size=20,
            xlim=lim,
            relative=relative,
            appendix=relative,
        )
        plt.close()

    # Mortality
    result = func_select_outcome_df(
        outcome="dead_post_6", results_csv=r"OUT_MORTALITY_HETEROGENEITY.csv"
    )
    coefplot(
        data=result,
        outcome="dead_post_6",
        tick_size=20,
        label_size=20,
        xlim=(-0.2, 0.2),
    )
    plt.close()

    # DI status/exit from DI
    result = func_select_outcome_df(
        outcome="status_pension_post4", results_csv="OUT_STATUS_HETEROGENEITY.csv"
    )
    coefplot(
        data=result,
        outcome="status_pension_post4",
        tick_size=20,
        label_size=20,
        xlim=(-0.2, 0.2),
    )
    plt.close()

    # Main earnings outcomes
    result = func_select_outcome_df(
        outcome="REGEMP_avg_rec", results_csv="OUT_LABOR_HETEROGENEITY.csv"
    )
    coefplot(
        data=result,
        outcome="REGEMP_avg_rec",
        tick_size=20,
        label_size=20,
        xlim=(-3000, 3000),
    )
    plt.close()

    result = func_select_outcome_df(
        outcome="MEMP_avg_rec", results_csv="OUT_LABOR_HETEROGENEITY.csv"
    )
    coefplot(
        data=result,
        outcome="MEMP_avg_rec",
        tick_size=20,
        label_size=20,
        xlim=(-500, 500),
    )
    plt.close()

    # Employment
    for outcome in "MEMP_rec", "REGEMP_rec":
        result = func_select_outcome_df(
            outcome=outcome, results_csv="OUT_LABOR_HETEROGENEITY.csv"
        )
        coefplot(
            data=result,
            outcome=outcome,
            tick_size=20,
            label_size=20,
            xlim=(-0.2, 0.2),
            appendix=True,
        )
        plt.close()

    for outcome in (
        "MEMP_post1",
        "MEMP_post2",
        "MEMP_post3",
        "MEMP_post4",
        "REGEMP_post1",
        "REGEMP_post2",
        "REGEMP_post3",
        "REGEMP_post4",
    ):
        result = func_select_outcome_df(
            outcome=outcome, results_csv="OUT_LABOR_HETEROGENEITY.csv"
        )
        coefplot(
            data=result,
            outcome=outcome,
            tick_size=20,
            label_size=20,
            xlim=(-0.2, 0.2),
            appendix=True,
        )
        plt.close()

    # Earnings (annual) marginal
    for outcome in (
        "MEMP_earnings_post1",
        "MEMP_earnings_post2",
        "MEMP_earnings_post3",
        "MEMP_earnings_post4",
    ):
        result = func_select_outcome_df(
            outcome=outcome, results_csv="OUT_LABOR_HETEROGENEITY.csv"
        )
        coefplot(
            data=result,
            outcome=outcome,
            tick_size=20,
            label_size=20,
            xlim=(-500, 500),
            appendix=True,
        )
        plt.close()

    # Earnings (annual) insured
    for outcome in (
        "REGEMP_earnings_post1",
        "REGEMP_earnings_post2",
        "REGEMP_earnings_post3",
        "REGEMP_earnings_post4",
    ):
        result = func_select_outcome_df(
            outcome=outcome, results_csv="OUT_LABOR_HETEROGENEITY.csv"
        )
        coefplot(
            data=result,
            outcome=outcome,
            tick_size=20,
            label_size=20,
            xlim=(-3000, 3000),
            appendix=True,
        )
        plt.close()

    print("---------------------------------------------------------------- \n")
    # Calculation of fiscal multiplier.
    compute_fiscal_multiplier()
    print("----------------------------------- End of script. \n")
