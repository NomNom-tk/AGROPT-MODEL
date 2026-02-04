# library imports
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import logging
import sys

### LOGGING DEBUG< WRITES TO LOGGING FILE
LOG_LEVEL = logging.INFO
logging.basicConfig(
    level=LOG_LEVEL,
    format="%(asctime)s | %(levelname)s | %(message)s",
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler("analysis.log", mode="w")
    ]
)

# Regression model imports
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_absolute_error, r2_score, mean_squared_error

# further stats imports
import statsmodels.api as sm

# import csv
#df = pd.read_csv("/AGROPT-MODEL/data/data_complete_anonymised.csv") # home file read
df = pd.read_csv("/home/agropt/AGROMOD/AGROPT-MODEL/data/data_complete_anonymised.csv")

"""
Requirement already satisfied: six>=1.5 in /usr/lib/python3/dist-packages (from python-dateutil>=2.8.2->pandas) (1.16.0)
Installing collected packages: tzdata, python-dateutil, numpy, pandas
  WARNING: The scripts f2py and numpy-config are installed in '/home/alfajor/.local/bin' which is not on PATH.
  Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.
Successfully installed numpy-2.2.6 pandas-2.3.3 python-dateutil-2.9.0.post0 tzdata-2025.3

WARNING: The scripts fonttools, pyftmerge, pyftsubset and ttx are installed in '/home/alfajor/.local/bin' which is not on PATH.
  Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.
"""
# =================
# initial data check
# =================
print(df.head())
logging.info(df.columns.tolist())
logging.info("\n missing values per column:")
logging.debug(df.isnull().sum())

# list for subfactors
# t1

t1_subfactors = [
    'DBAttitudesT1.DB1.',
    'DBAttitudesT1.DB2.',
    'DBAttitudesT1.DB3.',
    'DBAttitudesT1.DB4.',
    'DBAttitudesT1.DB5.'
]

# t2
t2_subfactors = [
    'DBAttitudesT2.DB1.',
    'DBAttitudesT2.DB2.',
    'DBAttitudesT2.DB3.',
    'DBAttitudesT2.DB4.',
    'DBAttitudesT2.DB5.'
]

# list other important columns
condition_col = 'Condition'
pro_reduction_col = 'Pro_reduction'
debate_id_col = 'ID_Group_all'
agent_id_col = 'ID'

# ===============
# calc for t1 and t2 mean attitude
# ===============
## t1 mean creat column with subfactor values as mean, axis=1 is to do row-wise calculations
df['attitude_t1'] = df[t1_subfactors].mean(axis=1)
df['attitude_t2'] = df[t2_subfactors].mean(axis=1)

## attitude change from t1 to t2
df['attitude_change'] = df['attitude_t2'] - df['attitude_t1'] # final - initial

## printing to check which agents changed their opinion and in which direction
logging.info(df['attitude_change'])
logging.info(df['attitude_t1'].head())

logging.debug(f"agents who become MORE pro-reduction: {(df['attitude_change'] > 0).sum()}")
logging.debug(f"agents who become LESS pro-reduction: {(df['attitude_change'] < 0).sum()}")
logging.debug(f"agents who did not change: {(df['attitude_change'] == 0).sum()}")

# filtering for homogeneous and heterogeneous debates and including control (next step to analyze, discuss)
df_wo_control = df[df['Condition'] != 'Control'].copy()
df_homo = df[df['Condition'] == 'Homogeneous'].copy()
df_hetero = df[df['Condition'] == 'Heterogeneous'].copy()
df_control = df[df['Condition'] == 'Control'].copy()

## data type check and subsequent filtering
if df_hetero[pro_reduction_col].dtype == 'object': # string type
   df_hetero_anti = df_hetero[df_hetero['Pro_reduction'] == 0].copy()
   df_hetero_pro = df_hetero[df_hetero['Pro_reduction'] == 1].copy() 
else: # numeric type
   df_hetero_anti = df_hetero[df_hetero['Pro_reduction'] == 0].copy()
   df_hetero_pro = df_hetero[df_hetero['Pro_reduction'] == 1].copy()

## check split of agents
if len(df_hetero_anti) + len(df_hetero_pro) == len(df_hetero):
  logging.debug("heterogeneous split checked")
else:
  logging.debug("warning: heterogeneous split doesn't add up")
  logging.debug(f"missing agents: {len(df_hetero) - len(df_hetero_anti) - len(df_hetero_pro)}")


# =============
# prediction errors
# =============
def prediction_errors(
  model,
  x,
  y_actual,
  agent_id_col,
  debate_id_col,
  condition_col,
  pro_reduction_col,
  df_source,
  save_path=None
):
    """
    Calculate prediction errors for a given model and dataset.

    Parameters:
    ----------
    model : sklearn-like model
        The fitted regression model.
    X : pd.DataFrame
        Feature data (e.g., t1_subfactors).
    y_actual : pd.Series or np.array
        Actual target values (e.g., attitude_t2 or simulated data).
    agent_id_col : str
        Column name for agent IDs.
    debate_id_col : str
        Column name for debate IDs.
    condition_col : str
        Column name for debate condition.
    pro_reduction_col : str
        Column name for agent's pro/anti stance.
    df_source : pd.DataFrame
        The dataframe containing all relevant columns (agent IDs, condition, etc.). 
        This is used to create a copy and add predicted values/errors without overwriting original data.
    save_summary : bool, default False
        If True, saves summary/error tables to CSV.

    Returns:
    -------
    df_errors : pd.DataFrame
        DataFrame containing predicted values, errors, and absolute errors.
    metrics : dict
        Dictionary with MAE, Median AE, Max error.
    """
    # make a prediction
    y_predict = model.predict(x)

    # copy of df to hold errors
    df_errors = df_source.copy()
    df_errors['predicted'] = y_predict
    df_errors['error'] = df_errors['predicted'] - y_actual
    df_errors['abs_error'] = np.abs(df_errors['error'])

    # metrics calculation
    metrics = {
      'MAE': df_errors['abs_error'].mean(),
      'MAE_VAR': df_errors['abs_error'].var(),
      'Median MAE': df_errors['abs_error'].median(),
      'Max MAE': df_errors['abs_error'].max()
    }
    ## summary stats by claude
    logging.info("\n" + "="*50)
    logging.info("PREDICTION ERROR ANALYSIS")
    logging.info("="*50)
    logging.info(f"Mean MAE: {metrics['MAE']:.4f}")
    logging.info(f"MAE Variance: {metrics['MAE_VAR']:.4f}")
    logging.info(f"Median MAE: {metrics['Median MAE']:.4f}")
    logging.info(f"Max error: {metrics['Max MAE']:.4f}")

    # worst 10 predictions
    logging.info("\n10 worst predictions")
    worst = df_errors.nlargest(10, 'abs_error')[
      [agent_id_col, debate_id_col, condition_col, pro_reduction_col, 'predicted', 'abs_error'] 
    ]
    logging.info(worst.to_string(index=False))

    #save to summary uncomment if needed   
    if save_path is not None:
      df_errors.to_csv(save_path, index=False)
      logging.debug(f"\n prediction errors summary saved to: {save_path}")
    return df_errors, metrics


# =============
# visualizations and function
# =============
## plot_coeff function creates df, take t1 values and predicts t2 attitudes
def plot_coefficients(
    model,
    title,
    save_path,
    subfactor_names=t1_subfactors
):
    """
    Plot and save a horizontal bar chart of regression coefficients.

    This function is designed for models that predict T2 attitude
    using T1 subfactors, but can be reused for other linear models
    if the feature list is provided explicitly.

    Parameters
    ----------
    model : fitted sklearn linear model
        A fitted model exposing `model.coef_`.
        Example: LinearRegression trained on T1 subfactors.
        - input is only based on csv values --> delimited as y (y-actual when you change the output 
        -- i.e. for predictions errors between hetero/homo models)

    title : str
        Plot title (used in figure and paper output).

    save_path : str
        File path where the plot will be saved (e.g., PNG).

    subfactor_names : list of str, optional
        Feature names in the SAME ORDER as used during model fitting.
        Defaults to `t1_subfactors`, reflecting the T1 → T2 design.
    """

    # --------------------------------------------------
    # Safety check: ensure coefficient–label alignment
    # --------------------------------------------------
    if len(subfactor_names) != len(model.coef_):
        raise ValueError(
            "Number of subfactor names does not match "
            "number of model coefficients."
        )

    # --------------------------------------------------
    # Create aligned coefficient DataFrame
    # --------------------------------------------------
    coef_df = pd.DataFrame({
        'Subfactor': subfactor_names,
        'Coefficient': model.coef_
    })

    # Sort by absolute importance
    coef_df['Abs_Coef'] = np.abs(coef_df['Coefficient'])
    coef_df = coef_df.sort_values('Abs_Coef', ascending=True)

    # Color by coefficient sign
    colors = ['red' if x < 0 else 'green' for x in coef_df['Coefficient']]

    # --------------------------------------------------
    # Plot
    # --------------------------------------------------
    fig, ax = plt.subplots(figsize=(10, 6))

    bars = ax.barh(
        coef_df['Subfactor'],
        coef_df['Coefficient'],
        color=colors,
        alpha=0.5
    )

    ax.axvline(x=0, color='black', linestyle='--', linewidth=1)
    ax.set_xlabel('Coefficient Value', fontsize=10, fontweight='bold')
    ax.set_ylabel('Subfactor', fontsize=10, fontweight='bold')
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.grid(axis='x', alpha=0.5)

    # --------------------------------------------------
    # Add coefficient value labels
    # --------------------------------------------------
    for bar, value in zip(bars, coef_df['Coefficient']):
        x_pos = value + (0.001 if value > 0 else -0.001)
        y_pos = bar.get_y() + bar.get_height() / 2

        ax.text(
            x_pos,
            y_pos,
            f'{value:.3f}',
            va='center',
            ha='left' if value > 0 else 'right',
            fontsize=10,
            fontweight='bold'
        )

    plt.tight_layout()
    plt.savefig(save_path, dpi=300, bbox_inches='tight')
    plt.show()

def plot_coefficients_comparison(
    model_1,
    model_2=None,
    subfactor_names=t1_subfactors,
    title="Coefficient Comparison",
    save_path=None,
    labels=("Model 1", "Model 2")
):
    """
    Plot regression coefficients side by side for comparison.

    Parameters
    ----------
    model_1 : fitted sklearn model
        First model to plot.
    model_2 : fitted sklearn model, optional
        Second model to plot for side-by-side comparison.
    subfactor_names : list of str
        Feature names in the same order as model coefficients.
    title : str
        Plot title.
    save_path : str
        Path to save the figure (PNG).
    labels : tuple
        Labels for the models (model_1, model_2).
    """

    # Check alignment
    if len(subfactor_names) != len(model_1.coef_):
        raise ValueError("Length of subfactor_names does not match model_1 coefficients.")
    if model_2 is not None and len(subfactor_names) != len(model_2.coef_):
        raise ValueError("Length of subfactor_names does not match model_2 coefficients.")

    # Prepare x-axis
    x = np.arange(len(subfactor_names))
    width = 0.35

    fig, ax = plt.subplots(figsize=(12, 6))

    # Plot bars
    ax.bar(x - width/2, model_1.coef_, width, label=labels[0], alpha=0.7)
    if model_2 is not None:
        ax.bar(x + width/2, model_2.coef_, width, label=labels[1], alpha=0.7)

    # Formatting
    ax.set_xticks(x)
    ax.set_xticklabels(subfactor_names)
    ax.set_xlabel("Subfactor")
    ax.set_ylabel("Coefficient")
    ax.set_title(title)
    ax.axhline(0, color='black', linestyle='--', linewidth=1)
    ax.legend()
    ax.grid(axis='y', alpha=0.3)

    plt.tight_layout()
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
    plt.show()


# =========
# function to fit and plot -- usable for each model ( need to delcare model_*, )
# =========
def fit_model_and_analyze(
  df_input, model_name,
  subfactors=t1_subfactors,
  y_col='attitude_t2',
  df_input2=None,
  model_name2=None,
  save_prefix=''
):
  """
  model fits linear regression model, plots the coefficients and calculates the errors 
  // can also fit second model if df_input2 and model_name2 are provided, fits second model
  df_input: pd.Dataframe (coefficient data frame)
  model_name: str
  subactors: list
  y_col: str
  save_prefix: str for filename
  
    Saves only 3 files per model:
    1. *_coefficients.png - Visual bar chart of coefficients
    2. *_errors.csv - Individual agent predictions and errors
    3. *_stats.txt - Complete statistical summary (coefficients, p-values, R², etc.)

  """

  # model 1
  
  # debug 
  logging.info("we started the fit and analyze model")
  
  x1 = df_input[subfactors]
  y1 = df_input[y_col]
  
  
  ### SK LEARNN FIT
  # fit the linear regression
  model1_sklearn = LinearRegression()
  model1_sklearn.fit(x1, y1)

  # coefficient plot
  plot_coefficients(
    model1_sklearn,
    title=f"{model_name} - subfactor importance",
    save_path=f"{save_prefix}_{model_name}_coefficients.png"
  )

  # prediction errors calculation
  df_errors1, metrics1 = prediction_errors(
    model1_sklearn,
    x1,
    y_actual=y1,
    df_source=df_input,
    agent_id_col=agent_id_col, 
    debate_id_col=debate_id_col,
    condition_col=condition_col, 
    pro_reduction_col=pro_reduction_col,
    save_path=f"{save_prefix}_{model_name}_errors.csv"
  )
  
  ### fit with stats models (same regression with more output)
  x1_with_const = sm.add_constant(x1)
  model1_stats = sm.OLS(y1, x1_with_const)
  results1 = model1_stats.fit()
  
  ### stats print in console
  logging.info(f"stat summary {model_name}")
  logging.info(results1.summary())
  
  ### file save independent of others (_stats.txt)
  stats_path = f"{save_prefix}_{model_name}_stats.txt"
  with open(stats_path, 'w') as f:
        f.write(results1.summary().as_text())
  logging.debug(f"✓ Complete statistics saved to: {stats_path}")

  # Model 2 given multi model comparison
  if df_input2 is not None and model_name2 is not None:
    x2 = df_input2[subfactors]
    y2 = df_input2[y_col]
    
    ### SKLEARN fit
    model2_sklearn = LinearRegression()
    model2_sklearn.fit(x2, y2)
    

    plot_coefficients_comparison(
        model1_sklearn,
        model2_sklearn,
        title=f"{model_name} vs {model_name2} subfactor coefficients",
        save_path=f"{save_prefix}_{model_name}_vs_{model_name2}_coefficients.png",
        labels=(model_name, model_name2)
    )

    df_errors2, metrics2 = prediction_errors(
        model2_sklearn, x2, y_actual=y2, df_source=df_input2,
        agent_id_col=agent_id_col, debate_id_col=debate_id_col,
        condition_col=condition_col, pro_reduction_col=pro_reduction_col,
        save_path=f"{save_prefix}_{model_name2}_errors.csv"
    )
    
    ### fit with STATSMODELS
    x2_with_const = sm.add_constant(x2)
    model2_stats = sm.OLS(y2, x2_with_const)
    results2 = model2_stats.fit()
    
    ### stats print in console
    logging.info(f"stat summary {model_name}")
    logging.info(results2.summary())
    
    
     ### file save independent of others (_stats.txt)
    stats_path2 = f"{save_prefix}_{model_name2}_stats.txt"
    with open(stats_path2, 'w') as f:
        f.write(results2.summary().as_text())
    logging.debug(f"stats summary complete to {stats_path2}")
    

    return (model1_sklearn, df_errors1, metrics1, results1,
            model2_sklearn, df_errors2, metrics2, results2)


  return (model1_sklearn, df_errors1, metrics1, results1)

##### MODEL DECLA TEST###
## df without control (hetero and homo combined)
global_wo_control, df_errors_global_wocontrol, metrics_glob, stats_results = fit_model_and_analyze(
    df_input = df_wo_control.copy(),
    model_name= "Global without control",
    save_prefix= "global"    
)
