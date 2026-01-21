# library imports
import pandas as pd
import numpy as np
# import scikit
import matplotlib.pyplot as plt
import seaborn as sns

# machine learning imports
#from scikit.linear_model import LinearRegression
#from scikit.metrics import mean_absolute_error, r2_score, mean_squared_error

# import csv
df = pd.read_csv("/home/alfajor/AGROTECH/git repo agropt/AGROPT-MODEL/data/data_complete_anonymised.csv")

"""
Requirement already satisfied: six>=1.5 in /usr/lib/python3/dist-packages (from python-dateutil>=2.8.2->pandas) (1.16.0)
Installing collected packages: tzdata, python-dateutil, numpy, pandas
  WARNING: The scripts f2py and numpy-config are installed in '/home/alfajor/.local/bin' which is not on PATH.
  Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.
Successfully installed numpy-2.2.6 pandas-2.3.3 python-dateutil-2.9.0.post0 tzdata-2025.3

WARNING: The scripts fonttools, pyftmerge, pyftsubset and ttx are installed in '/home/alfajor/.local/bin' which is not on PATH.
  Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.
"""

# initial data check
print(df.head())
print(df.columns.tolist())

# list for subfactors
# t1
"""
t1_subfactors = [
    'DBAttitudesT1.DB1.',
    'DBAttitudesT1.DB2.',
    'DBAttitudesT1.DB3.',
    'DBAttitudesT1.DB4.',
    'DBAttitudesT1.DB5.'
]
"""

t1_subfactors = [
    'DBFactor4T1',
    'DBFactor3T1',
    'DBFactor2T1',
    'DBFactor1T1',
    'DBFactor5T1'
]

print(t1_subfactors)

# t2
t2_subfactors = [
    'DBAttitudesT2.DB1.',
    'DBAttitudesT2.DB2.',
    'DBAttitudesT2.DB3.',
    'DBAttitudesT2.DB4.',
    'DBAttitudesT2.DB5.'
]

# calc for t1 and t2 mean attitude
# t1 mean
df['attitude_t1'] = df[t1_subfactors].mean()
df['attitude_t2'] = df[t2_subfactors].mean()

# attitude change from t1 to t2
df['attitude_change'] = df['attitude_t1'] - df['attitude_t2']

print(df['attitude_t1'].head())