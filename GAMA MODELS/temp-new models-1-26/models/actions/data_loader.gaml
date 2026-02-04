model data_loader {
    action load_csv_data(string file_path) {
        write "=== LOADING CSV DATA ===";
        
        text_data <- csv_file(".data/data_complete_anonymised.csv", true);
        matrix data_matrix <- matrix(text_data);
        write "Total rows in file: " + data_matrix.rows + ", cols=" + data_matrix.columns;
        
        // headers
        headers <- data_matrix.headers;
        
        int start_row <- 1;
        
        
        /*/ first row is header if not extract manually
        list<string> headers <- [];
        loop col from: 0 to: data_matrix.columns -1 {
            headers << string(data_matrix[col, 0];
        }
        
        write "headers found: " + length(headers) + " columns";
        
        // data row start
        int start_row <- 1;
        
        / Load CSV file using GAMA's text_file function
        file text_data <- csv_file("/home/agropt/Gama_Workspace/models1/models/data/data_complete_anonymised.csv");
        
        // Parse CSV with built-in parser
        matrix data_matrix <- csv_file(text_data, separator =  ",");
        write "Total rows in file: " + data_matrix.rows;
        
        // Get column headers
        list<string> headers <- data_matrix.headers;


        // FALLBACK: If headers are missing 
        int start_row <- 0;
        if length(headers) = 0 {
            headers <- data_matrix[0]; // First row becomes header
            start_row <- 1;            // Data starts from row 1
            write "WARNING: Headers not auto-detected, using first row as header";
        }
	*/

        // ====================================================================
        // FIND COLUMN INDICES
        // ====================================================================
        int idx_id_group <- headers index_of "ID_Group_all";
        int idx_id <- headers index_of "ID";
        int idx_db_t1 <- headers index_of "DB_IndexT1";
        int idx_db_t2 <- headers index_of "DB_IndexT2";
        int idx_condition <- headers index_of "Condition";
        int idx_pro_reduction <- headers index_of "Pro_reduction";
        
        // Subfactor column indices (5 subfactors x 2 timepoints)
        list<int> idx_sub_t1 <- list_with(5, -1);
        list<int> idx_sub_t2 <- list_with(5, -1);
        
        // FIXED: Renamed loop variable from 'i' to 'j' to avoid shadowing
        loop j from: 1 to: 5 {
            idx_sub_t1[j-1] <- headers index_of ("DBAttitudesT1.DB" + j + ".");
            idx_sub_t2[j-1] <- headers index_of ("DBAttitudesT2.DB" + j + ".");
        }

        write "Column indices found";
        
        // ====================================================================
        // ERROR CHECKING: Verify all required columns exist
        // ====================================================================
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

        // Check subfactor column indices
        loop j from: 0 to: 4 {
            if idx_sub_t1[j] = -1 or idx_sub_t2[j] = -1 {
                write "ERROR: Subfactor " + (j+1) + " column not found!";
                return;
            }
        }
        
        // ====================================================================
        // INITIALIZE SUBFACTOR STORAGE
        // ====================================================================
        id_group_raw <- [];
    	agent_id_list <- [];
    	group_type_list <- [];
    	initial_attitude_list <- [];
    	final_attitude_list <- [];
    	pro_reduction_list <- [];
        
        subfactors_t1 <- list_with(5, []);
        subfactors_t2 <- list_with(5, []);
        
        // ====================================================================
        // PARSE DATA ROWS
        // ====================================================================
        loop row_idx from: start_row to: data_matrix.rows - 1 {
            // Basic identifiers
            id_group_raw << string(data_matrix[idx_id_group, row_idx]);
            agent_id_list << int(data_matrix[idx_id, row_idx]);

            // Attitudes (normalized from [-6, +6] to [0, 1])
            float raw_t1 <- float(data_matrix[idx_db_t1, row_idx]);
            float raw_t2 <- float(data_matrix[idx_db_t2, row_idx]);
            initial_attitude_list << (raw_t1 + 6.0) / 12.0;
            final_attitude_list << (raw_t2 + 6.0) / 12.0;

            // Group type and pro/anti classification
            group_type_list << string(data_matrix[idx_condition, row_idx]);
            pro_reduction_list << int(data_matrix[idx_pro_reduction, row_idx]);

            // Parse subfactors (normalized from [-6, +6] to [0, 1])
            loop j from: 0 to: 4 {
                float t1_val <- (float(data_matrix[idx_sub_t1[j], row_idx]) + 6.0) / 12.0;
                float t2_val <- (float(data_matrix[idx_sub_t2[j], row_idx]) + 6.0) / 12.0;
                
                subfactors_t1[j] << t1_val;
                subfactors_t2[j] << t2_val;
            }   
        }

        write "Successfully loaded " + length(agent_id_list) + " agents";
        
}
}
