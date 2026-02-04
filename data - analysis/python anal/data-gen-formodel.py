import pandas as pd
import numpy as np

# Configuration
np.random.seed(42)  # For reproducibility
num_debates = 30
agents_per_debate = 6

# Debate structure distribution
# Let's say: 40% homogeneous pro-meat, 40% homogeneous pro-reduction, 20% heterogeneous
debate_structures = (
    ['homogeneous_meat'] * 8 +  # 40%
    ['homogeneous_reduction'] * 8 +  # 40%
    ['heterogeneous'] * 8 + # 20%
    ['active control'] * 6 # 
)
np.random.shuffle(debate_structures)

data = []
agent_counter = 1

for debate_id in range(1, num_debates + 1):
    debate_type = debate_structures[debate_id - 1]
    
    # Determine group composition
    if debate_type == 'homogeneous_meat':
        groups = [2] * 6  # All pro-meat
    elif debate_type == 'homogeneous_reduction':
        groups = [1] * 6  # All pro-reduction
    elif debate_type == 'active control':
        groups = [3] * 6 # active control
    else:  # heterogeneous
        groups = [1] * 3 + [2] * 3  # Mixed
        np.random.shuffle(groups)
    
    for agent_idx in range(agents_per_debate):
        group_type = groups[agent_idx]
        
        # Q2: Random initial attitudes REGARDLESS of group (1-7)
        initial_attitude = np.random.randint(1, 8)
        
        # Q3: Opinion change based on group
        if group_type == 3:  # Control (if you add them)
            change = np.random.choice([-1, 0, 1], p=[0.2, 0.6, 0.2])
        else:  # Treatment
            change = np.random.choice([-2, -1, 0, 1, 2], p=[0.1, 0.2, 0.3, 0.2, 0.2])
        
        final_attitude = np.clip(initial_attitude + change, 1, 7)
        
        data.append({
            'debate_id': debate_id,
            'agent_id': agent_counter,
            'initial_attitude': initial_attitude,
            'final_attitude': final_attitude,
            'group_type': group_type
        })
        
        agent_counter += 1

# Create and save
df = pd.DataFrame(data)
df.to_csv('test_debates_30.csv', index=False)

# Summary statistics
print(f"Generated {len(df)} agents across {num_debates} debates")
print(f"\nDebate type distribution:")
print(f"  Homogeneous pro-meat: {debate_structures.count('homogeneous_meat')}")
print(f"  Homogeneous pro-reduction: {debate_structures.count('homogeneous_reduction')}")
print(f"  Heterogeneous: {debate_structures.count('heterogeneous')}")
print(f"\nGroup distribution:")
print(df['group_type'].value_counts())
print(f"\nOpinion changes:")
print(f"  Mean change: {(df['final_attitude'] - df['initial_attitude']).mean():.2f}")
print(f"  Std change: {(df['final_attitude'] - df['initial_attitude']).std():.2f}")