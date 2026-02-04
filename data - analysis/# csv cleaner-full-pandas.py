# csv cleaner-full-pandas

import pandas as pd

df = pd.read_csv("/home/agropt/AGROMOD/test_debates_10.csv")

# Report Generation as a txt
print("=====")
print("CSV data overview start")
print("=====")

# current date
date = pd.Timestamp.now()
print(date)

# basic data info / total rows, total columns, memory usage
rows, cols = df.shape
print(f"Total Rows: {rows}")
print(f"Total Columns: {cols}")
print(f"Memory Usage: {df.memory_usage().sum() / (1024 ** 2)} bytes")

# missing data / total missing value, columns with missing data
null_val = df.isnull().sum()

print(f"Missing Data:")
print(f"- Total Missing Values: {null_val.sum()}")
print



# data types / integer columns, float columns, object columns


# duplicates
dupli_dat = df.duplicated().sum()
print(dupli_dat)

# Report Generation as a txt end
#with open("csv report.txt", "x") as f:
#    f.write(#include all data lists, create f.write statements for each part, all calculations before passing to fwrite))


print("=====")
print("CSV data overview end")
print("=====")

# total nill values

print(null_val)

print(df.shape)
print(df.columns)
print(df.isnull().sum())
print(df.head())

