#!/usr/bin/env python3
# exp_launch.py
# Launches GAMA batch experiments in parallel with timing and logging

import os
import subprocess
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed
import time

# ── Config ──────────────────────────────────────────────────────────────────
GAMA_HEADLESS = "/home/stolte/Gama_lite/headless/gama-headless.sh"
MODEL_FILE    = "/home/stolte/GAMA_work/experiments/batch_exp_exh-20-3.gaml"
LOG_FILE      = "gama_run_log.txt"
MAX_PARALLEL  = 8   # ← set to 3 if server feels sluggish, 6 if 8 cores available

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
    "Bt_lhs_bipol_dist_speak",
]
# ────────────────────────────────────────────────────────────────────────────

def run_experiment(exp):
    """Run a single experiment and return its result."""
    start = time.time()
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] STARTING  {exp}")

    result = subprocess.run(
        [GAMA_HEADLESS, "-batch", exp, MODEL_FILE],
        capture_output=True, text=True
    )

    elapsed = time.time() - start
    mins, secs = divmod(int(elapsed), 60)
    duration = f"{mins}m{secs:02d}s"
    status = "OK" if result.returncode == 0 else "FAILED"
    timestamp_end = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    print(f"[{timestamp_end}] {status:<6}  {exp}  ({duration})")

    return {
        "exp":       exp,
        "status":    status,
        "duration":  duration,
        "elapsed":   elapsed,
        "timestamp": timestamp_end,
        "stderr":    result.stderr,
        "returncode": result.returncode,
    }


def write_log(results):
    with open(LOG_FILE, "a") as log:
        log.write(f"\n{'='*60}\n")
        log.write(f"Run started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        log.write(f"{'='*60}\n")
        for r in results:
            log.write(f"[{r['timestamp']}] {r['status']:<6} {r['exp']}  ({r['duration']})\n")
            if r["returncode"] != 0:
                log.write(f"  STDERR:\n{r['stderr']}\n")


def main():
    total_start = time.time()
    n = len(experiments)
    print(f"\nLaunching {n} experiments, {MAX_PARALLEL} in parallel\n" + "─"*50)

    results = []
    with ThreadPoolExecutor(max_workers=MAX_PARALLEL) as executor:
        futures = {executor.submit(run_experiment, exp): exp for exp in experiments}
        for future in as_completed(futures):
            results.append(future.result())

    # ── Summary ──────────────────────────────────────────────────────────────
    total_elapsed = time.time() - total_start
    total_mins, total_secs = divmod(int(total_elapsed), 60)
    ok     = [r for r in results if r["status"] == "OK"]
    failed = [r for r in results if r["status"] == "FAILED"]

    print("\n" + "─"*50)
    print(f"Completed {len(ok)}/{n} OK  |  {len(failed)} failed  |  total {total_mins}m{total_secs:02d}s")
    if failed:
        print("Failed experiments:")
        for r in failed:
            print(f"  ✗ {r['exp']}")

    write_log(results)
    print(f"Log written to {LOG_FILE}\n")


if __name__ == "__main__":
    main()
