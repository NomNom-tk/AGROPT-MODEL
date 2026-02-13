# URGENT 2-HOUR ACTION PLAN
## For Coding Supervisor Meeting - SA Improvements

---

## CRITICAL CODE ISSUES FOUND (Fix These First - 30 min)

### 🔴 Issue 1: Hardcoded Parameters in Network Code (HIGHEST PRIORITY)

**Location:** `main-4-2-26.gaml` lines in `create_network` action

**Problem:**
```gama
int k <- 4; // Number of nearest neighbors - HARDCODED!
if flip(0.1) { // Rewiring probability - HARDCODED!
```

**Fix RIGHT NOW:**
```gama
// ADD to global parameters section (top of main file):
int small_world_k <- 4 parameter: "Small-world K neighbors" category: "Network" min: 2 max: 8;
float small_world_rewire <- 0.1 parameter: "Small-world rewiring prob" category: "Network" min: 0.0 max: 0.3;

// CHANGE in create_network action:
int k <- small_world_k;  // was: int k <- 4;
if flip(small_world_rewire) {  // was: if flip(0.1) {
```

**Why critical:** Can't do SA on network parameters if they're hardcoded!

---

### 🔴 Issue 2: Opinion Bounds Missing in Consensus/Clustering

**Location:** `opinion_agent.gaml` in consensus and clustering reflexes

**Problem:** Opinions could theoretically go <0 or >1, but bipolarization has bounds

**Fix:**
```gama
// CONSENSUS reflex - ADD bounds:
reflex consensus_formation when: model_type = "consensus" {
    if length(neighbors) > 0 {
        previous_opinion <- opinion;
        list<float> all_opinions <- [opinion] + (neighbors collect each.opinion);
        float new_opinion <- mean(all_opinions);
        opinion <- max([0.0, min([1.0, opinion + convergence_rate * (new_opinion - opinion)])]);  // ← ADD THIS
        color <- rgb(opinion * 255, 0, (1 - opinion) * 255);
    }
}

// CLUSTERING reflex - ADD bounds:
reflex bounded_confidence when: model_type = "clustering" {
    if length(neighbors) > 0 {
        previous_opinion <- opinion;
        list<opinion_agent> similar_neighbors <- neighbors where (
            abs(each.opinion - self.opinion) <= confidence_threshold
        );
        if length(similar_neighbors) > 0 {
            list<float> similar_opinions <- similar_neighbors collect each.opinion;
            float avg_similar <- mean(similar_opinions);
            opinion <- max([0.0, min([1.0, opinion + convergence_rate * (avg_similar - opinion)])]);  // ← ADD THIS
            color <- rgb(opinion * 255, 0, (1 - opinion) * 255);
        }
    }
}
```

---

### 🟡 Issue 3: Inconsistent Color Mapping (Nice to fix - 5 min)

**Make all three models use same color scheme:**

```gama
// Replace all color assignments with this standardized version:
color <- rgb(opinion * 255, 0, (1 - opinion) * 255);

// Remove the special bipolarization color code (lines with if opinion < 0.5)
```

---

## MODEL ELEMENTS CORRECTIONS (What to show supervisor - 15 min)

### Add These Parameters to Your Chart:

```markdown
## 2. SOCIAL INFLUENCE MODEL PARAMETERS (Parametric)

| Element ID | Name | Default Value | Plausible Range | Model | Notes |
|------------|------|---------------|-----------------|-------|-------|
| SI1 | convergence_rate | 0.2 | [0.05, 0.5] | All | μ - speed of opinion change |
| SI2 | confidence_threshold | 0.5 | [0.1, 0.8] | Clustering, Bipolarization | ε - similarity for attraction |
| SI3 | repulsion_threshold | 0.6 | [0.5, 1.0] | Bipolarization only | ρ - dissimilarity for repulsion |
| SI4 | repulsion_strength | 0.1 | [0.05, 0.3] | Bipolarization only | α - strength of repulsive force |

## 3. NETWORK PARAMETERS (Parametric)

| Element ID | Name | Default Value | Plausible Range | Network Type | Notes |
|------------|------|---------------|-----------------|--------------|-------|
| NET1 | network_type | "complete" | {complete, random, small_world} | All | Categorical - which topology |
| NET2 | connection_probability | 0.3 | [0.2, 0.8] | Random only | Prob of each link forming |
| NET3 | small_world_k | 4 | {2, 4, 6, 8} | Small-world only | Nearest neighbors in ring |
| NET4 | small_world_rewire | 0.1 | [0.05, 0.2] | Small-world only | Rewiring probability |

## 4. SUBFACTOR WEIGHT PARAMETERS (Parametric)

| Element ID | Name | Default Value | Plausible Range | Notes |
|------------|------|---------------|-----------------|-------|
| W1 | weight_subfactor_1 | 0.2 | [0.0, 1.0] | Normalized automatically |
| W2 | weight_subfactor_2 | 0.2 | [0.0, 1.0] | Normalized automatically |
| W3 | weight_subfactor_3 | 0.2 | [0.0, 1.0] | Normalized automatically |
| W4 | weight_subfactor_4 | 0.2 | [0.0, 1.0] | Normalized automatically |
| W5 | weight_subfactor_5 | 0.2 | [0.0, 1.0] | Normalized automatically |

## 5. SIMULATION CONTROL PARAMETERS

| Element ID | Name | Default Value | Plausible Range | Notes |
|------------|------|---------------|-----------------|-------|
| SIM1 | max_cycles | 100 | [50, 200] | Maximum simulation length |
| SIM2 | mae_convergence_threshold | 0.001 | [0.0001, 0.01] | Stopping criterion |
| SIM3 | selected_debate_id | 1 | [1, max_debates] | Which debate to simulate |
```

---

## WHAT TO SHOW SUPERVISOR IN MEETING (1 hour prep)

### 1. Corrected Model Specification Document (30 min)

**Create file: `model_specification.md`**

```markdown
# ABM Model Specification - Opinion Dynamics

## 1. Agent Characteristics

**State Variables:**
- opinion ∈ [0,1] - current attitude toward meat reduction
- initial_opinion ∈ [0,1] - starting attitude (from weighted subfactors)
- final_attitude ∈ [0,1] - empirical target (from survey T2)
- neighbors - list of connected agents
- subfactor_1_t1...subfactor_5_t1 - initial subfactor values
- debate_id - which debate group
- pro_reduction ∈ {0,1} - binary classification

**Initial Opinion Calculation:**
```
initial_opinion = Σ(w_i × subfactor_i) / Σ(w_i)
where w_i are calibrated weights (default: equal weights)
```

## 2. Opinion Update Mechanisms (3 Models)

### Model 1: Consensus (Assimilative)
**Formula:**
```
x_i(t+1) = x_i(t) + μ × (mean(x_i ∪ N_i) - x_i(t))
```
**Parameters:** μ (convergence_rate) ∈ [0.05, 0.5]

### Model 2: Bounded Confidence (Clustering)
**Formula:**
```
N_i^similar = {j ∈ N_i : |x_j - x_i| ≤ ε}
x_i(t+1) = x_i(t) + μ × (mean(N_i^similar) - x_i(t))
```
**Parameters:** 
- μ (convergence_rate) ∈ [0.05, 0.5]
- ε (confidence_threshold) ∈ [0.1, 0.8]

### Model 3: Bipolarization (Attraction-Repulsion)
**Formula:**
```
For each neighbor j:
  if |x_j - x_i| ≤ ε: attraction zone
  if ε < |x_j - x_i| < ρ: neutral zone
  if |x_j - x_i| ≥ ρ: repulsion zone

x_i(t+1) = clamp(x_i(t) + μ × attraction_force + α × repulsion_force, 0, 1)
```
**Parameters:**
- μ (convergence_rate) ∈ [0.05, 0.5]
- ε (confidence_threshold) ∈ [0.1, 0.8]
- ρ (repulsion_threshold) ∈ [0.5, 1.0]
- α (repulsion_strength) ∈ [0.05, 0.3]

## 3. Network Structure

**Three topologies controlled by network_type:**

**Complete:** All agents in debate connected
- Degree: n-1

**Random:** Erdős-Rényi random graph
- Parameter: connection_probability ∈ [0.2, 0.8]
- Expected degree: (n-1) × p

**Small-world:** Watts-Strogatz model
- Parameters: k ∈ {2,4,6,8}, p_rewire ∈ [0.05, 0.2]
- Ring lattice + random shortcuts

**Key constraints:**
- Debates isolated (no cross-debate links)
- Control group excluded
- Static networks (no dynamic rewiring)

## 4. Simulation Dynamics

**Initialization:**
1. Load agent data from CSV
2. Compute initial_opinion from weighted subfactors
3. Create network structure
4. Set opinion = initial_opinion

**Update Loop:**
1. Each cycle: all agents execute opinion update reflex (simultaneous)
2. Check convergence every 5 cycles (max opinion change < threshold)
3. Stop when converged OR max_cycles reached

**Output:**
- MAE = mean(|opinion_final - final_attitude|)
- Per-agent, per-debate, and global metrics
```

---

### 2. Quick SA Plan Summary (15 min)

**Create file: `SA_plan_summary.md`**

```markdown
# Sensitivity Analysis Plan - Quick Summary

## Phase 1: Parameter Screening (Already set up in batch mode)

**Currently testing:**
- convergence_rate: [0.05, 0.1, 0.2, 0.3, 0.5]
- confidence_threshold: [0.1, 0.3, 0.5, 0.7]
- repulsion_threshold: [0.5, 0.6, 0.8]
- repulsion_strength: [0.05, 0.1, 0.2]

**Need to add:**
- network_type: {complete, random, small_world}
- subfactor weights: systematic variation

## Phase 2: Network Sensitivity (NEW)

**Test combinations:**
```
For each model_type (consensus, clustering, bipolarization):
  For each network_type (complete, random, small_world):
    Run with baseline parameters
    Compare MAE
```

**Questions to answer:**
1. Does network structure matter?
2. Which model is most robust to network choice?
3. Do results depend on network × model interaction?

## Phase 3: Robustness Check (After calibration)

**Method:** Latin Hypercube Sampling
- Sample 100-200 parameter combinations
- Check: What % of configurations beat regression baseline?
- Identify: Which parameters matter most?

## Computational Budget

| Phase | Configs | Reps | Debates | Total Runs |
|-------|---------|------|---------|------------|
| 1. Grid | ~100 | 1 | 55 | 5,500 |
| 2. Network | 9 | 5 | 10 | 450 |
| 3. LHS | 200 | 1 | 55 | 11,000 |
| **Total** | | | | **~17,000** |

Estimated time: ~8 hours with parallelization
```

---

### 3. Code Improvements Checklist (15 min)

**Print this and show what you've done:**

```markdown
# Code Improvements for SA

## ✅ Already Implemented
- [x] Three social influence models (consensus, clustering, bipolarization)
- [x] Three network structures (complete, random, small-world)
- [x] Batch experiment framework
- [x] MAE computation (global and per-debate)
- [x] Convergence detection
- [x] Parameter sweeps for main SI parameters
- [x] Per-agent results export

## 🔧 Fixed Today (show these in meeting)
- [x] Hardcoded k=4 → now parameter small_world_k
- [x] Hardcoded p=0.1 → now parameter small_world_rewire
- [x] Added opinion bounds to consensus/clustering models
- [x] Standardized color mapping across models
- [x] Documented all model elements in chart

## 📋 Next Steps (discuss priorities)
- [ ] Add network_type to batch experiments
- [ ] Test network × model interactions
- [ ] Implement LHS sampling for robustness
- [ ] Add Sobol analysis (if time permits)
- [ ] Compare to regression baseline
```

---

## TALKING POINTS FOR SUPERVISOR (What to say)

### Opening (2 min)

"I received feedback that my protocol lacks proper SA. I've been working through the Borgonovo et al. paper and identified several concrete improvements to the code. I want to show you what I've fixed and get your input on priorities for the next steps."

### Show Code Fixes (5 min)

**Point 1:** "I found hardcoded parameters in the network code that prevented SA. I've now parameterized them."
- Show before/after of `small_world_k` and `small_world_rewire`

**Point 2:** "I standardized the opinion update rules across models - they now all have proper bounds."
- Show the `max([0.0, min([1.0, ...])])` additions

**Point 3:** "I've documented all model elements systematically."
- Show the model elements chart with all parameters listed

### Discuss SA Plan (10 min)

"Here's my phased SA approach. Which do you think is realistic given my timeline?"

**Show the 3 phases:**
1. Parameter screening (already running)
2. Network sensitivity (new - need to implement)
3. Robustness check (after calibration)

**Ask:**
- "Is Phase 2 (network sensitivity) worth doing, or should I stick with complete network?"
- "For Phase 3, is 200 LHS samples reasonable or should I do more?"
- "Should I implement Sobol analysis or is that overkill for a [Master's/PhD]?"

### Technical Questions (5 min)

**Question 1:** "The network code creates directed edges in random/small-world. Should I make them undirected?"
- Show the code section
- Explain: Agent A might influence B, but B might not influence A

**Question 2:** "I'm initializing opinion from weighted subfactors. Should subfactor weights be in the SA?"
- Currently using equal weights (0.2 each)
- Could calibrate optimal weights

**Question 3:** "How many debates should I use for calibration vs validation?"
- Currently thinking 20% (11 debates) calibration, 80% (44 debates) validation
- Is this ratio sensible?

### Close (3 min)

"What's the minimum viable SA you'd want to see in the protocol before the next full team meeting?"

**Listen for:**
- Which phases are essential
- Which can be deferred
- Any other code issues they spot

---

## FILES TO PREPARE BEFORE MEETING

### 1. Model Specification Document
- Copy the markdown above
- Save as `model_specification.md`
- Have it open in VS Code to show

### 2. Updated Model Elements Chart
- Fix the table in VS Code
- Add all the new parameter rows
- Format it nicely

### 3. SA Plan Summary
- Copy the markdown above
- Save as `SA_plan_summary.md`

### 4. Code with Fixes
- Make the 4 critical fixes (30 min)
- Commit to Git (if using version control)
- Have files open to show before/after

### 5. Quick Demo
- Run one batch experiment with new parameters
- Show output files
- Demonstrate that network parameters now vary

---

## IF YOU ONLY HAVE 2 HOURS TOTAL

### Absolute Minimum (1 hour):

1. **Fix hardcoded network parameters** (15 min)
2. **Add opinion bounds to consensus/clustering** (10 min)
3. **Update model elements chart** with all parameters (20 min)
4. **Write 1-page SA plan summary** (15 min)

### Use remaining hour for:
- Practice explaining the fixes (10 min)
- Prepare answers to likely questions (20 min)
- Test that code still runs (15 min)
- Review Borgonovo paper again (15 min)

---

## EXPECTED SUPERVISOR REACTIONS & RESPONSES

### If they say: "This is too much work"
**Response:** "I've broken it into phases. Phase 1 is already running. I'm asking which of Phases 2-3 you think are essential vs. nice-to-have."

### If they say: "Why didn't you do this earlier?"
**Response:** "I wasn't aware of the Borgonovo framework - it wasn't in my reading list. I'm working to catch up now and want to make sure I'm prioritizing correctly."

### If they say: "The network code is wrong"
**Response:** "I suspected the directed edge issue. Should I implement undirected connections? I can do that quickly." (Shows you're thinking ahead)

### If they say: "What about argumentation models?"
**Response:** "I'm focusing on getting the social influence models right first. Argumentation can be Phase 4 if time permits." (Shows prioritization skills)

---

## POST-MEETING ACTION ITEMS

After the meeting, immediately:

1. **Email summary** (5 min):
   ```
   Thanks for the meeting. Here's what we agreed:
   - Priority 1: [X]
   - Priority 2: [Y]
   - Deferred: [Z]
   - Next checkpoint: [date]
   ```

2. **Update protocol** with agreed SA plan (30 min)

3. **Implement agreed changes** to code (timeline depends on priorities)

4. **Schedule next check-in** (suggest 2 weeks)

---

## CONFIDENCE BUILDERS

**You can honestly say:**

✅ "I've identified all model parameters systematically"
✅ "I've fixed the hardcoded values that were preventing SA"
✅ "I have a phased SA plan with computational estimates"
✅ "I'm using proper validation practices (calibration vs test split)"
✅ "I'm comparing multiple model variants, not just one"

**What you're asking for:**
- Guidance on scope (which phases are essential)
- Technical review (network code correctness)
- Reality check (computational feasibility)

This shows maturity and initiative, not helplessness.

---

Good luck! You've got this. The fixes are straightforward, and you have concrete things to show. Remember: the goal is NOT to have everything perfect, it's to show you understand the issues and have a plan to address them.
