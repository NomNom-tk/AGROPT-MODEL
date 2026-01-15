# debate_analysis

# library loading
import pandas as pd
import numpy
import matplotlib.pyplot as plt
import seaborn
import plotly
import kaleido

df1 = pd.read_csv("/home/agropt/AGROMOD/AGROPT-MODEL/data/test files for debate_anal/test_11.csv")
df2 = pd.read_csv("/home/agropt/AGROMOD/AGROPT-MODEL/data/test files for debate_anal/test_22.csv")
df3 = pd.read_csv("/home/agropt/AGROMOD/AGROPT-MODEL/data/test files for debate_anal/test_33.csv")

combined_df = pd.concat([df1, df2, df3], ignore_index=True, sort=False)

# initial overview
rows, cols = combined_df.shape
comb_dat_type = combined_df.dtypes
print(f"{rows} rows, {cols} columns")
print(comb_dat_type)
print(combined_df.head(5))

# unique debates
unique_debates = combined_df['selected_debate_id'].unique()
# print(unique_debates)

# store results
results = []

# filtering on unique debates
for debate_id in unique_debates:
    # filter for one debate
    debate_data = combined_df[combined_df['selected_debate_id'] == debate_id]
    
    # minimum mae for each model
    best_per_model = {}
    
    for model in ['consensus', 'clustering', 'bipolarization']:
            model_data = debate_data[debate_data['model_type'] == model]
            
            # check for data
            if len(model_data) > 0:
                # index of row with min mae
                best_idx = model_data['mae'].idxmin()
                
                # entire row using the index
                best_row = model_data.loc[best_idx]
                
                # store
                best_per_model[model] = best_row
if best_per_model:
    # lowest mae
    winner = min(best_per_model.items(), key = lambda x: x[1]['mae'])
    winner_model = winner[0] # model name
    winner_data = winner[1] # row data
    
    # store results for debate i
    results.append({
        'debate_id': debate_id,
        'winner_model': winner_model,
        'winner_mae': winner_data['mae'],
        'consensus_mae': best_per_model['consensus']['mae'] if 'consensus' in best_per_model else None,
        'clustering_mae': best_per_model['clustering']['mae'] if 'clustering' in best_per_model else None,
        'bipolarization_mae': best_per_model['bipolarization']['mae'] if 'bipolarization' in best_per_model else None, 
    })
    
    best_models = pd.DataFrame(results)
    print(best_models.head())
    
# counting model wins & mae stats
#consensus_wins = (best_models['winner_model'] == 'consensus').sum()
#clustering_wins = (best_models['winner_model'] == 'clustering').sum()
#bipolarization_wins = (best_models['winner_model'] == 'bipolarization').sum()

## mae stats
def calcul_model_summary(best_models):
    
    summary_data = []

    for model in ['consensus', 'clustering', 'bipolarization']:
        wins = (best_models['winner_model'] == model).sum()
    
        mae_column = f'{model}_mae'
    
        # stats
        mean_mae = best_models[mae_column].mean()
        std_mae = best_models[mae_column].std()
    
        # win pct
        win_pct = (wins / len(best_models)) * 100
    
        # append results
        summary_data.append({
            'model': model,
            'wins': wins,
            'mean_mae': mean_mae,
            'std_mae': std_mae,
            'win_pct': win_pct
        })
    
    return pd.DataFrame(summary_data).set_index('model')

model_summary = calcul_model_summary(best_models)
#print(model_summary)

# singular debate analysis (one at a time, need to call funciton after and specify one debate)
def analyze_individual_debate(combined_df, debate_id):
    # one debate data selection
            sing_debate_data = combined_df[combined_df['selected_debate_id'] == debate_id]
    
            for model in ['consensus', 'clustering', 'bipolarization']:
                model_dat_singulardeb = sing_debate_data[sing_debate_data['model_type'] == model]
                if len(model_dat_singulardeb) > 0:
                    best_idx = model_dat_singulardeb['mae'].idxmin()
                    best_row = model_dat_singulardeb.loc[best_idx]
            
                    # stats
                    min_mae = model_dat_singulardeb['mae'].min()
                    max_mae = model_dat_singulardeb['mae'].max()
                    std_mae = model_dat_singulardeb['mae'].std()
            
                    # test print
                    print(f"\n{model.upper()}:")
                    print(f"  Best MAE: {best_row['mae']:.4f}")
                    print(f"  Best Parameters:")
                    print(f"    Convergence Rate: {best_row['convergence_rate']}")
                    print(f"    Confidence Threshold: {best_row['confidence_threshold']}")
                    print(f"  Statistics:")
                    print(f"    MAE Range: {min_mae:.4f} - {max_mae:.4f}")
                    print(f"    MAE Std Dev: {std_mae:.4f}")
    # can run singular debate
    ## analyze_individual_debate(combined_df, 21)



def analyze_all_debates(combined_df):
    # one debate data selection
            unique_debates = combined_df['selected_debate_id'].unique()
    
            for debate_id in unique_debates:
                analyze_individual_debate(combined_df, debate_id)
    
# comparing the best model for a specific debate            
def compare_models_for_one_debate(combined_df, debate_id):
    debate_data = combined_df[combined_df['selected_debate_id'] == debate_id]
    comparison = []
    
    for model in ['consensus', 'clustering', 'bipolarization']:
        model_data = debate_data[debate_data['model_type'] == model]
        
        if len(model_data) > 0:
            best_idx = model_data['mae'].idxmin()
            best_row = model_data.loc[best_idx]
            
            comparison.append({
                'Model': model.capitalize(),
                'Best_MAE': best_row['mae'],
                'Conv_Rate': best_row['convergence_rate'],
                'Conf_Thresh': best_row['confidence_threshold'],
                'Rep_Thresh': best_row['repulsion_threshold'],
                'Rep_Str': best_row['repulsion_strength'],
                'Conv_cycle': best_row['convergence_cycle']
                
            })
    comparison_df = pd.DataFrame(comparison)
        
    if len(comparison_df) > 0:
        best_mae_idx = comparison_df['Best_MAE'].idxmin()
        
        # extra output
        # ADD THESE LINES for nice formatting:
        print(f"\n{'='*80}")
        print(f"MODEL COMPARISON FOR DEBATE {debate_id}")
        print(f"{'='*80}")
        print(comparison_df.to_string(index=False))
        print(f"\n✨ WINNER: {comparison_df.loc[best_mae_idx, 'Model']} "
              f"(MAE = {comparison_df.loc[best_mae_idx, 'Best_MAE']:.4f})")
    else:
        print(f"\nNo data available for debate {debate_id}")
        
    return comparison_df

results_tes = compare_models_for_one_debate(combined_df, 21)
print(results_tes)