import pandas as pd

from extract_table import build_and_save_outcome_table

def extract_status_table(
    df_path,
    controls_path,
    output_path,
):
    """Table for effects on DI exit."""
    df = pd.read_csv(df_path)
    df_covs = pd.read_csv(controls_path)

    outcomes = [
        [
            "status_pension_post1",
            "status_pension_post2",
            "status_pension_post3",
            "status_pension_post4",
            "status_pension_post5",
        ]
    ]

    table = build_and_save_outcome_table(
        df=df,
        df_covs=df_covs,
        outcomes=outcomes,
        output_path=output_path,
    )

    return table
