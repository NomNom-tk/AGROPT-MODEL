# csv cleaner-full-pandas

# how to use
## compile the file in an ide
## cd to wd then launch with python3 "csv_cleaner.py" <filename.csv>

import pandas as pd
import sys
import os
import numpy as np
#import matplotlib.pyplot as plt

# compatible with other file types
if len(sys.argv) > 2:
    print("Usage: python3 csv_cleaner.py <filename.csv>")
    sys.exit(1)

filename = sys.argv[1]

# checking if file exists
if not os.path.exists(filename):
    print(f"Error: File '{filename} not found!")
    sys.exit(1)

df = pd.read_csv("/home/agropt/AGROMOD/test_debates_10.csv", on_bad_lines='warn')

# vars for the report
# current date
date = pd.Timestamp.now()

# basic data info / total rows, total columns, memory usage
rows, cols = df.shape
mem_use = {df.memory_usage().sum() / (1024 **2)}

# missing data / total missing value, columns with missing data
null_val = df.isnull().sum()
null_val_sum = null_val.sum()

# filter to show columns with missing values
missing_columns = null_val[null_val > 0]

# data types / integer columns, float columns, object columns
type_counts = df.dtypes.value_counts()  

# duplicates
dupli_dat = df.duplicated().sum()

# Report Generation as a txt end
with open("csv report_1.txt", "w") as f:
     f.write("=" * 50 + "\n")
     f.write("CSV quality report")
     f.write("=" * 50 + "\n")
     f.write(f"Date: {date}\n\n")
     
     # basic information
     f.write("Basic Information:\n")
     f.write(f"Total Rows: {rows}\n")
     f.write(f"Total Columns: {cols}\n")
     f.write(f"Memory Usage: {df.memory_usage().sum() / (1024 ** 2)} bytes\n\n")

     # missing data
     f.write("Missing Data:\n")
     f.write(f"- Total Missing Values: {null_val.sum()}\n")
     if len(missing_columns) > 0:
         f.write("- Columns with missing data:\n")
         for column_name, missing_count in missing_columns.items():
            f.write(f"  * {column_name}: {missing_count} missing\n")
     else:
         f.write("- No missing data found\n")
     f.write("\n")
     
     # data types
     f.write("Data Types:\n")
     for dtype, count in type_counts.items():
         f.write(f"- {dtype}: {count}: columns\n")
     f.write("\n")
     
     # duplicates
     f.write("Duplicates:\n")
     f.write(f"- Duplicate rows found: {dupli_dat}\n\n")
     
     # detailed missing data locations
     f.write("=" * 50 + "\n")
     f.write("Detailed missing data info:\n")
     f.write("=" * 50 + "\n\n")
     for column in df.columns:
         missing_rows = df[df[column].isnull()].index.tolist()
         if len(missing_rows) > 0:
            f.write(f"{column}:\n")
            f.write(f" Rows: {missing_rows}\n\n")
     f.write("=" * 50 + "\n")
     f.write("End of Report\n")
    