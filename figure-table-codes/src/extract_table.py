import pandas as pd


def build_and_save_outcome_table(df: pd.DataFrame,
                                 df_covs: pd.DataFrame,
                                 outcomes: list,
                                 output_path: str,
                                 keys=("(1)", "(2)")) -> pd.DataFrame:
    table = create_outcome_table_tex(df=df, outcomes=outcomes)
    tables_covs = create_outcome_table_tex(df=df_covs, outcomes=outcomes)
    combined = pd.concat([table, tables_covs], axis=1, keys=keys)
    combined = combined.reorder_levels([1, 0], axis=1).sort_index(axis=1)
    combined.to_latex(output_path, escape=False)
    return combined


def extract_table(df, subsample):
    tab = df[df.subsample == subsample].copy()
    tab["Coef"] = tab.Coefficent.round(3).astype(str) + tab.PValue.apply(lambda p: "*"*(p<0.05) + "*"*(p<0.01) + "*"*(p<0.001))
    tab["StandardError"] = "(" + tab.StandardError.round(4).astype(str) + ")"
    tab["Bandwidth"] = "[" + tab.Bandwidth.round(1).astype(str) + "]"
    tab["ControlMean"] = r"\textit{" + tab.ControlMean.round(2).astype(str) + "}"
    #tab[["Variable","Coef","StandardError","ControlMean","Observations","PValue"]].to_latex(f"rdd-{subsample}.tex", index=False)
    return tab[["Variable","Coef","StandardError","ControlMean","Observations","Bandwidth"]]


def create_outcome_table_tex(df, outcomes):

    sets = ["aall", "male", "female"]
    tables=[]
    for o in outcomes:
        columns = []
        for set in sets:
            c=extract_table(df, set)
            print(c)
            c = c.loc[c.Variable.isin(
                o
                )][
                    ["Variable","Coef", "StandardError", "Bandwidth", "ControlMean", "Observations"]
                    ].set_index("Variable").stack()
            columns.append(c)

        t=pd.concat(columns, axis=1)
        t["empty"] = ""
        t=t.reset_index()
        t=t.drop(columns="level_1")
        t = t.set_index(["Variable", "empty"])
        t.columns = sets
        tables.append(t)

    return pd.concat(tables)