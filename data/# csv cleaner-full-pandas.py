# csv cleaner-full-pandas

import pandas as pd

df = pd.read_csv("/home/agropt/AGROMOD/test_debates_10.csv")

# Report Generation as a txt
print("=====")
print("CSV data overview")
print("=====")

# current date
date = pd.Timestamp()
print(date)

# basic data info / total rows, total columns, memory usage

# missing data / total missing value, columns with missing data

# data types / integer columns, float columns, object columns

# duplicates

# file save
df.to_txt("debates-overview.txt", index=False)

# total nill values
null_val = df.isnull().sum()
print(null_val)

print(df.shape)
print(df.columns)
print(df.isnull().sum())
print(df.head())

