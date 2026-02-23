model data_loader 

import "../main-16-2-26-homophily fix.gaml"

    global {
        /**
         * CSV DATA LOADER
         * 
         * REQUIRED GLOBAL VARIABLES in importing model:
         * - list<string> id_group_raw
         * - list<int> agent_id_list
         * - list<string> group_type_list
         * - list<float> initial_attitude_list
         * - list<float> final_attitude_list
         * - list<int> pro_reduction_list
         * - list<list<float>> subfactors_t1
         * - list<list<float>> subfactors_t2
         */
         
         // RAW DATA LISTS (loaded from CSV)
    	list<string> id_group_raw;              // Group identifiers from CSV
    	list<int> agent_id_list;                // Individual agent IDs
    	list<string> group_type_list;           // Condition: "Homogeneous", "Heterogeneous", "Control"
    	list<float> initial_attitude_list;      // T1 attitudes (DB_IndexT1)
    	list<float> final_attitude_list;        // T2 attitudes (DB_IndexT2) - target values
    	list<int> debate_id_list;               // Computed debate group IDs
    	list<int> pro_reduction_list;           // Binary: 1=pro, 0=anti
        
        action load_csv_data(string file_path) {
            write "=== LOADING CSV DATA ===";

            // Load CSV file
            file text_data <- csv_file(file_path, ",", string, false);
            matrix data_matrix <- matrix(text_data);
            write "Total rows in file: " + data_matrix.rows + ", cols=" + data_matrix.columns;
            
            // extract headers
            list<string> headers <- [];
            
            loop col from: 0 to: data_matrix.columns - 1 {
                // get cell value
                unknown cell_value <- data_matrix[col, 0];
                
                // convert to string
                string header_name <- "" + cell_value; // forces string conversion
                
                // add to list
                headers <- headers + header_name; 
                
                // debug for the first few
                if col < 5 {
                    write " Col " + col + ": '" + header_name + "' (type: " + type_of(cell_value) + ")"; 
            
                }
            }
            
            write "Total headers extracted: " + length(headers);
    	    write "First 10 headers: " + headers;
            
            int start_row <- 1; // data starts at row 1

            /*/ headers test v1
            list<string> headers <- data_matrix.contents[0]; // first row is headers
            
            write "Headers: " + length(headers) + "columns";
            write "first 5 headers: " + copy_between(headers, 0, min(5, length(headers)));
            
            int start_row <- 1;
            
            // Get headers
            /list<string> headers <- data_matrix.headers;
            //list<string> headers <- data_matrix row_at 0;
            list<string> headers;
            int start_row <- 0;
            
            write "DEBUG: headers variable type: " + type_of(headers);
    	    write "DEBUG: headers length: " + length(headers);
    	    write "DEBUG: headers content: " + headers;
            
            // Print raw first row
    	    if data_matrix.rows > 0 and data_matrix.columns > 0 {
                write "Raw first cell [0,0]: '" + data_matrix[0,0] + "'";
        	if data_matrix.columns > 1 {
            	    write "Raw second cell [1,0]: '" + data_matrix[1,0] + "'";
        	}
    	    }
	    
	    
            // Fallback if headers missing
            if length(headers) = 0 {
                headers <- data_matrix[0];
                start_row <- 1;
                write "WARNING: Headers not auto-detected, using first row as header";
            }
            */

            // Find column indices
            int idx_id_group <- headers index_of "ID_Group_all";
            int idx_id <- headers index_of "ID";
            int idx_db_t1 <- headers index_of "DB_IndexT1";
            int idx_db_t2 <- headers index_of "DB_IndexT2";
            int idx_condition <- headers index_of "Condition";
            int idx_pro_reduction <- headers index_of "Pro_reduction";

            // Subfactor column indices (5 subfactors x 2 timepoints)
            list<int> idx_sub_t1 <- list_with(5, -1);
            list<int> idx_sub_t2 <- list_with(5, -1);

            loop j from: 1 to: 5 {
                idx_sub_t1[j-1] <- headers index_of ("DBFactor" + j + "T1");
                idx_sub_t2[j-1] <- headers index_of ("DBFactor" + j + "T2");
            }

            write "Column indices found";

            // VERBOSE ERROR CHECKING
            if idx_id_group = -1 {
                write "ERROR: Column 'ID_Group_all' not found!";
                write "Available columns: " + headers;
                return;
            }
            if idx_id = -1 {
                write "ERROR: Column 'ID' not found!";
                write "Available columns: " + headers;
                return;
            }
            if idx_db_t1 = -1 {
                write "ERROR: Column 'DB_IndexT1' not found!";
                write "Available columns: " + headers;
                return;
            }
            if idx_db_t2 = -1 {
                write "ERROR: Column 'DB_IndexT2' not found!";
                write "Available columns: " + headers;
                return;
            }
            if idx_condition = -1 {
                write "ERROR: Column 'Condition' not found!";
                write "Available columns: " + headers;
                return;
            }
            if idx_pro_reduction = -1 {
                write "ERROR: Column 'Pro_reduction' not found!";
                write "Available columns: " + headers;
                return;
            }

            // Check subfactor columns
            loop j from: 0 to: 4 {
                if idx_sub_t1[j] = -1 or idx_sub_t2[j] = -1 {

                    string col_t1 <- "DBFactor" + (j + 1) + "T1";
                    string col_t2 <- "DBFactor" + (j + 1) + "T2";

                    write "ERROR: Subfactor " + (j+1) + " column not found!";
                    write "Looking for: '" + col_t1 + "'and '" + col_t2;
                    write "Available columns: " + headers;
                    return;
                }
            }

            // Initialize storage
            id_group_raw <- [];
            agent_id_list <- [];
            group_type_list <- [];
            initial_attitude_list <- [];
            final_attitude_list <- [];
            pro_reduction_list <- [];
            subfactors_t1 <- list<list<float>>(list_with(5, []));
            subfactors_t2 <- list<list<float>>(list_with(5, []));

            // Parse data rows
            loop row_idx from: start_row to: data_matrix.rows - 1 {
                // Basic identifiers
                id_group_raw << string(data_matrix[idx_id_group, row_idx]);
                agent_id_list << int(data_matrix[idx_id, row_idx]);

                // Attitudes normalized [-6, +6] -> [0,1]
                float raw_t1 <- float(data_matrix[idx_db_t1, row_idx]);
                float raw_t2 <- float(data_matrix[idx_db_t2, row_idx]);
                initial_attitude_list << (raw_t1 + 6.0) / 12.0;
                final_attitude_list << (raw_t2 + 6.0) / 12.0;

                // Group type and pro/anti classification
                group_type_list << string(data_matrix[idx_condition, row_idx]);
                pro_reduction_list << int(data_matrix[idx_pro_reduction, row_idx]);

                // Parse subfactors (normalized [1-7] -> [0,1])
                loop j from: 0 to: 4 {
                    float t1_val <- (float(data_matrix[idx_sub_t1[j], row_idx]) - 1.0) / 6.0;
                    float t2_val <- (float(data_matrix[idx_sub_t2[j], row_idx]) - 1.0) / 6.0;
                    subfactors_t1[j] << t1_val;
                    subfactors_t2[j] << t2_val;
                }
            }

            write "Successfully loaded " + length(agent_id_list) + " agents";
        }
    }
