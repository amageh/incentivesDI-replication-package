def get_mechanical_effect(B1, B2, D, extension_rate, permanent=False):
    """Calculate the mechanical effect of a reform to the DI program."""
    if permanent:
        return B2 - B1
    else:
        return (B2 - B1) * (D * (1 - extension_rate) + extension_rate)


def get_behavioural_effect(
    B2, tax, D, extension_rate, epsilon_t, epsilon_e, permanent=False
):
    """Calculate the behavioural effect of a reform to the DI program."""
    if permanent:
        benefits = epsilon_t * B2
        taxes = epsilon_t * tax
        takeup_effect = benefits + taxes
        extension_effect = 0
    else:
        benefits = B2 * epsilon_t * (D * (1 - extension_rate) + extension_rate)
        taxes = tax * epsilon_t * (D * (1 - extension_rate) + extension_rate)
        takeup_effect = benefits + taxes

        benefits = B2 * (epsilon_e * (1 - D))
        taxes = tax * (epsilon_e * (1 - D))
        extension_effect = benefits + taxes

    return takeup_effect, extension_effect


def calculate_multiplier(
    B1: float,
    B2: float,
    tax: float,
    D: float,
    p_perm: float,
    extension_rate: float,
    epsilon_t: float,
    epsilon_e: float,
    return_multiplier=True,
):
    """
    Calculate the fiscal multiplier based on mechanical and behavioural effects.
    Parameters:
    B1 (float): Baseline benefit level.
    B2 (float): Post-reform benefit level.
    tax (float): Tax amount.
    D (float): Proportion of temporary recipients.
    p_perm (float): Proportion of permanent recipients.
    extension_rate (float): Proportion of temporary recipients who
        receive an extension.
    epsilon_t (float): Take-up elasticity.
    epsilon_e (float): Extension elasticity.
    return_multiplier (bool): Whether to return the fiscal multiplier or
        the individual components.
    Returns:
    float: Fiscal multiplier if return_multiplier is True, otherwise a tuple
        of mechanical and behavioural effects
    """
    M_p = get_mechanical_effect(B1, B2, D, extension_rate, permanent=True)
    M_t = get_mechanical_effect(B1, B2, D, extension_rate, permanent=False)
    B_p_takeup, B_p_extension = get_behavioural_effect(
        B2=B2,
        tax=tax,
        D=D,
        extension_rate=extension_rate,
        epsilon_t=epsilon_t,
        epsilon_e=epsilon_e,
        permanent=True,
    )
    B_t_takeup, B_t_extension = get_behavioural_effect(
        B2=B2,
        tax=tax,
        D=D,
        extension_rate=extension_rate,
        epsilon_t=epsilon_t,
        epsilon_e=epsilon_e,
        permanent=False,
    )
    if return_multiplier:
        return 1 + (
            (
                p_perm * (B_p_takeup + B_p_extension)
                + (1 - p_perm) * (B_t_takeup + B_t_extension)
            )
            / (p_perm * M_p + (1 - p_perm) * M_t)
        )
    else:
        return M_p, M_t, B_p_takeup, B_p_extension, B_t_takeup, B_t_extension


def compute_fiscal_multiplier():
    """Calculate fiscal multiplier based on mechanical and behavioural effects of a reform to the DI program."""
    # Average annual DI benefit.
    B1 = 9180
    # Calculation for 1 percent change in benefits.
    B2 = B1 * 1.01
    # Average tax paid by recipients in sample in working state.
    tax = 3487
    # Share of permanent DI in sample.
    p_perm = 0.35

    # Average duration of temporary DI as share of time until retirement.
    # Temporary DI lasts 3 years, average DI recipient in sample is
    # 49 and has 16 years until retirement at 65 for our sample. So D=3/16=0.19.
    D = 0.19

    # Baseline extension rate of DI benefits for temporary recipients.
    extension_rate = 0.95

    # Elasticities:
    # Weigh takeup-elasticity by share of 50-60 year olds (58%)in DI population.
    # (assumes elasticity of 0 for age group below 50)
    # Replace weight with 1 to apply elasticity to all DI recipients.
    epsilon_t = 0.0058* 0.58
    # Extension elasticity (all temporary recipients).
    epsilon_e = 0.0017

    # Calculate mechanical and behavioural effects, and fiscal multiplier.
    M_p, M_t, B_p_takeup, B_p_extension, B_t_takeup, B_t_extension = (
        calculate_multiplier(
            B1=B1,
            B2=B2,
            tax=tax,
            D=D,
            p_perm=p_perm,
            extension_rate=extension_rate,
            epsilon_t=epsilon_t,
            epsilon_e=epsilon_e,
            return_multiplier=False,
        )
    )

    # Calculate fiscal multiplier.
    multiplier = calculate_multiplier(
        B1=B1,
        B2=B2,
        tax=tax,
        D=D,
        p_perm=p_perm,
        extension_rate=extension_rate,
        epsilon_t=epsilon_t,
        epsilon_e=epsilon_e,
        return_multiplier=True,
    )
    total_effect_p = B_p_takeup + B_p_extension + M_p
    total_effect_t = B_t_takeup + B_t_extension + M_t

    # Print results.
    print("-------------- CALCULATING FISCAL MULTIPLIER -------------- \n")
    print(
        f"Behavioural takeup effect permanent: {round(B_p_takeup,2)}, temporary: {round(B_t_takeup,2)}"
    )
    print(
        f"Behavioural extension effect permanent: {round(B_p_extension,2)}, temporary: {round(B_t_extension,2)}"
    )
    print(f"Mechanical effect permanent: {round(M_p,2)}, temporary: {round(M_t,2)}")
    print(
        f"Total effect permanent: {round(total_effect_p,2)}, temporary: {round(total_effect_t,2)}"
    )
    print("\n")
    # multiplier = 1+ ((p_perm * (B_p_takeup+B_p_extension) + (1- p_perm) * (B_t_takeup+B_t_extension)) / (p_perm* M_p + (1-p_perm)*M_t))
    multiplier_no_exit = 1 + (B_p_takeup / M_p)
    # multiplier_no_exit_elasticity = 1+((p_perm * (B_p_takeup) + (1- p_perm) * (B_p_takeup)) / (p_perm* M_p + (1-p_perm)*M_t))

    print(f"Fiscal Multiplier: {round(multiplier,4)}")
    print(f"Fiscal Multiplier ignoring exit from DI: {round(multiplier_no_exit,4)}")
    # print(f"Fiscal Multiplier with exit but no exit elasticity: {round(multiplier_no_exit_elasticity,4)}")
    print("\n")

    # save everything to a tex file
    with open("../out/fiscal_multiplier.tex", "w") as f:
        f.write(f"Fiscal Multiplier: {round(multiplier,4)} \\\\ \n")
        f.write(
            f"Fiscal Multiplier ignoring exit from DI: {round(multiplier_no_exit,4)} \\\\ \n"
        )
        # f.write(f"Fiscal Multiplier with exit but no exit elasticity: {round(multiplier_no_exit_elasticity,4)} \\\\ \n")
        f.write(
            f"Behavioural takeup effect permanent: {round(B_p_takeup,2)}, temporary: {round(B_t_takeup,2)} \\\\ \n"
        )
        f.write(
            f"Behavioural extension effect permanent: {round(B_p_extension,2)}, temporary: {round(B_t_extension,2)} \\\\ \n"
        )
        f.write(
            f"Mechanical effect permanent: {round(M_p,2)}, temporary: {round(M_t,2)} \\\\ \n"
        )
        f.write(
            f"Total effect permanent: {round(total_effect_p,2)}, temporary: {round(total_effect_t,2)} \\\\ \n"
        )
