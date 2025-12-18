# results aggregation per debate (instead of per sim)

import pandas as pd

# change to absolute file path for usr
results = pd.read_csv("/home/agropt/Gama_Workspace/agro-pt/models/models/outputs/batch_summary.csv")

debate_summary = results.groupby('selected_debate_id').agg({
    'mae' : ['mean', 'std', 'min', 'max'],
    'convergence_cycle' : 'mean',
    'opinion_variance' : 'mean',
    'polarization_index' : 'mean'
}).reset_index()

# flatten multi-level columns 
new_columns = []
for col in debate_summary.columns:
    if isinstance(col, tuple):
        # Join multi-level column names
        new_name = '_'.join(str(x) for x in col if x)
        new_columns.append(new_name)
    else:
        # Single-level column (like selected_debate_id)
        new_columns.append(col)

debate_summary.columns = new_columns

print("Columns after flattening:", debate_summary.columns.tolist())

# counts of simulations per debate
debate_counts = results.groupby('selected_debate_id').size().reset_index(name='n_simulations')
debate_summary = debate_summary.merge(debate_counts, on='selected_debate_id')


# change path for usr
debate_summary.to_csv("/home/agropt/Gama_Workspace/agro-pt/models/models/outputs/debate_sum_aggreg.csv", index=False)

print(f"save aggregated summary with {len(debate_summary)} debates")
print("\ncolumn names:", debate_summary.columns.tolist())
print("\first few rows:")
print(debate_summary.head())