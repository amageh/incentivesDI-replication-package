import pandas as pd
import warnings
from extract_table import build_and_save_outcome_table

warnings.filterwarnings("ignore")


def extract_mortality_table(
    df_path,
    controls_path,
    output_path,
):
    """Mortality table with estimates for mortality effects of DI reform."""
    df = pd.read_csv(df_path)
    df_covs = pd.read_csv(controls_path)

    outcomes = [["dead_post_3", "dead_post_6"]]

    table = build_and_save_outcome_table(
        df=df,
        df_covs=df_covs,
        outcomes=outcomes,
        output_path=output_path,
    )

    return table
