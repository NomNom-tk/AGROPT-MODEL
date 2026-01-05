# csv-cleaner

# file open
#filename = "test_debates_10.csv"

with open("/home/agropt/AGROMOD/test_debates_10.csv") as file:
    lines = file.readlines()
    
    # header read
    first_line = lines[0]
    header_parts = first_line.strip().split(',')
    expected_columns = len(header_parts)
    
    print(f"Expected {expected_columns} columns")
    print(f"Header: {header_parts}")
    print("----")
    
    for i, line in enumerate(lines[1:], start=2):
        parts = line.strip().split(',')
        num_columns = len(parts)
        
        # checking actual to expected columns
        if num_columns != expected_columns:
            print(f"file contains {num_columns} and expected {expected_columns}")
            print(f" content: {parts}")
        else:
            print(f"line {i} is ok columns {num_columns}")
