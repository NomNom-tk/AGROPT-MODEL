# designed to launch experiments sequentially
# imports
import os
import subprocess
from datetime import datetime

# chmod the file before running
# chmod +x exp_launch.py

GAMA_HEADLESS = "/home/stolte/Gama_lite/headless/gama-headless.sh"
MODEL_FILE = "/home/stolte/GAMA_work/AGROP/experiments/batch_exp_exh-20-3.gaml"

experiments = [
    "Bt_lhs_no_change",
    "Bt_lhs_cons_ndist",
    "Bt_lhs_cons_dist",
    "Bt_lhs_cons_ndist_speak",
    "Bt_lhs_cons_dist_speak",
    "Bt_lhs_clst_ndist",
    "Bt_lhs_clst_dist",
    "Bt_lhs_clst_ndist_speak",
    "Bt_lhs_clst_dist_speak",
    "Bt_lhs_bipol_ndist",
    "Bt_lhs_bipol_dist",
    "Bt_lhs_bipol_ndist_speak",
    "Bt_lhs_bipol_dist_speak"
]

# terminal feedback for exps
for exp in experiments:
    print(f"Running {exp}...")  # terminal feedback so you know it's alive
    
    result = subprocess.run(
        [GAMA_HEADLESS, "-batch", exp, MODEL_FILE],
        capture_output=True, text=True
    )
    
    status = 'OK' if result.returncode == 0 else 'FAILED'
    print(f"Finished {exp}: {status}")  # terminal feedback


# log errors to output file
with open("gama_run_log.txt", "a") as log:
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    if result.returncode != 0:
        log.write(f"[{timestamp}] {exp}: FAILED\n")
        log.write(result.stderr)
    else:
        log.write(f"[{timestamp}] {exp}: OK\n")
        
