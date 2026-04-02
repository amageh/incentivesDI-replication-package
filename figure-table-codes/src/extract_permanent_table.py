
import pandas as pd
import warnings

from extract_table import build_and_save_outcome_table

warnings.filterwarnings('ignore')


def extract_permanent_table(
    df_path="../data/appendix_OUT_PERMANENT_SAMPLE_CONTROLS0.csv",
    controls_path="../data/appendix_OUT_PERMANENT_SAMPLE_CONTROLS1.csv",
    output_path="../out/permanent-overall.tex",
):
    """Table for effects on permanent recipients (Appendix)"""
    df = pd.read_csv(df_path)
    df_covs = pd.read_csv(controls_path)
    outcomes = [["MEMP_rec", "REGEMP_rec", "dead_post_6"]]

    table = build_and_save_outcome_table(
        df=df,
        df_covs=df_covs,
        outcomes=outcomes,
        output_path=output_path,
    )

    return table
