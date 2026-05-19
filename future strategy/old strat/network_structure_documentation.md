# CORRECTED: B2 - Neighbor Definition & Network Structure

---

## What Your Code Actually Does

You have **THREE network types** controlled by the `network_type` parameter:

### Network Type 1: Complete (Fully Connected)
```gama
neighbors <- opinion_agent where (
    each != self and
    each.debate_id = self.debate_id and
    each.group_type != "Control"
);
```

**Meaning:** 
- Every agent is connected to EVERY other agent in their debate
- Control group agents are excluded
- Network is static (doesn't change during simulation)

### Network Type 2: Random
```gama
neighbors <- opinion_agent where (
    each != self and
    each.debate_id = self.debate_id and
    each.group_type != "Control" and
    flip(connection_probability)
);
```

**Meaning:**
- Each potential connection has probability `connection_probability` of forming
- Expected degree: (n-1) × connection_probability
- Network is static after initialization
- Can create isolated agents if probability is low

### Network Type 3: Small World
```gama
// Ring lattice: Connect to k nearest neighbors
loop j from: 1 to: k {
    int neighbor_index <- (i + j) mod length(agent_list);
    if agent_list[neighbor_index].debate_id = current.debate_id {
        current.neighbors <- current.neighbors + agent_list[neighbor_index];
    }
}

// Rewire with probability 0.1
if flip(0.1) {
    opinion_agent random_neighbor <- one_of(...);
    if random_neighbor != nil {
        current.neighbors <- current.neighbors + random_neighbor;
    }
}
```

**Meaning:**
- Start with ring lattice (k=4 nearest neighbors)
- 10% chance of adding random long-range connection
- Creates clusters with occasional shortcuts (Watts-Strogatz model)
- Network is static after initialization

---

## Key Properties Across All Networks

**Debate Isolation:**
- Agents ONLY connect to others in their debate (`each.debate_id = self.debate_id`)
- No cross-debate influence
- Each debate is a separate social network

**Control Group:**
- Control agents (`group_type = "Control"`) are excluded from all networks
- They have NO neighbors
- Their opinions don't update (no social influence)

**Static Networks:**
- All networks are created once at initialization
- They do NOT change during simulation
- No dynamic rewiring based on opinion changes

**Asymmetric Connections (Potential Issue):**
- Code shows DIRECTED network construction
- Agent A might have B as neighbor, but B might not have A
- Is this intentional or a bug?

---

## Corrected Table Entry for B2



| Element ID | Name                                    | Default Rule                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | Alternative Rules to Test                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | Source                                                                                   |
| ---------- | --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| B2         | Network Structure & Neighbor Definition | **Network controlled by `network_type` parameter:**<br><br>**Complete Network (default?):**<br>• Fully connected within each debate<br>• Formula: neighbors = {all agents in same debate} \ {self, control}<br>• Degree: n-1 where n = debate size<br>• Static network<br><br>**Random Network:**<br>• Probabilistic connections within debate<br>• Parameter: `connection_probability`<br>• Expected degree: (n-1) × p<br>• Static after initialization<br><br>**Small World Network:**<br>• Watts-Strogatz model<br>• Ring lattice (k=4 neighbors) + rewiring (p=0.1)<br>• Creates clustering with shortcuts<br>• Static after initialization<br><br>**Key constraints:**<br>• Debates are isolated (no cross-debate links)<br>• Control group excluded from network<br>• All networks are STATIC (no dynamic rewiring) | **For Sensitivity Analysis:**<br><br>**Within network types:**<br>1. Random: vary connection_probability [0.3, 0.5, 0.7, 1.0]<br>2. Small-world: vary k [2, 4, 6] and rewiring p [0.05, 0.1, 0.2]<br><br>**Across network types:**<br>3. Compare Complete vs Random vs Small-world<br><br>**Alternative topologies:**<br>4. Scale-free (preferential attachment)<br>5. Spatial network (if you had location data)<br>6. Dynamic network (rewire based on opinion similarity)<br><br>**Alternative update rules:**<br>7. Sequential vs simultaneous updates<br>8. Asynchronous (probabilistic activation)<br>9. Ordered by opinion extremity | Watts & Strogatz (1998) for small-world<br>Erdős-Rényi for random<br>Your implementation |

---

## Critical Questions About Your Network Code

### 🚨 Issue 1: Directed vs Undirected Network

Your code creates DIRECTED edges. Example:

```gama
// Agent A's neighbor list
ask agent_A {
    neighbors <- opinion_agent where (...flip(0.5)...);
    // A -> B might form
}

// Agent B's neighbor list  
ask agent_B {
    neighbors <- opinion_agent where (...flip(0.5)...);
    // B -> A might NOT form
}
```

**Result:** Agent A influences B, but B might not influence A

**Is this intentional?** 

If you want UNDIRECTED (symmetric) network:
- Need to ensure: if A is in B's neighbors, then B is in A's neighbors
- Current code doesn't guarantee this for random/small-world

**For complete network:** This is fine (everyone connects to everyone anyway)

**For random/small-world:** You might have asymmetric influence

---

### 🚨 Issue 2: Small World k=4 is Hardcoded

```gama
int k <- 4; // Number of nearest neighbors
```

**This should be a parameter!** For sensitivity analysis, you want to test k=2, k=4, k=6, etc.

**Fix:**
```gama
// Add to global parameters
int small_world_k <- 4 parameter: "Small-world nearest neighbors" category: "Network";

// Use in code
int k <- small_world_k;
```

---

### 🚨 Issue 3: Small World Rewiring p=0.1 is Hardcoded

```gama
if flip(0.1) {
```

**Same issue - should be parameter:**

```gama
// Add to global parameters  
float small_world_rewiring <- 0.1 parameter: "Small-world rewiring probability" category: "Network";

// Use in code
if flip(small_world_rewiring) {
```

---

### 🚨 Issue 4: Random Network Connection Probability Not Shown

I see `flip(connection_probability)` in the code, but is this defined as a parameter?

**Should be:**
```gama
float connection_probability <- 0.5 parameter: "Random network connection probability" category: "Network";
```

**And needs range for calibration:** [0.2, 0.8]

---

## Updated Parametric Elements Table

Add these to your **Section 2: Network Parameters**:

| Element ID | Name                   | Default Value | Plausible Range                 | Notes                                                   |
| ---------- | ---------------------- | ------------- | ------------------------------- | ------------------------------------------------------- |
| NET1       | network_type           | "complete"    | {complete, random, small_world} | Categorical choice of network structure                 |
| NET2       | connection_probability | 0.5           | [0.2, 0.8]                      | For random network only; prob of each link forming      |
| NET3       | small_world_k          | 4             | {2, 4, 6, 8}                    | For small-world only; nearest neighbors in ring lattice |
| NET4       | small_world_rewiring   | 0.1           | [0.05, 0.1, 0.2, 0.3]           | For small-world only; prob of adding random shortcut    |

---

## What This Means for Your Hypotheses

### H4: Heterogeneous vs Homogeneous Debates

**CRITICAL:** Your network structure might INTERACT with debate type!

**Example:**
- In complete network: All agents influence all others equally
- In random network: Some agents might be isolates
- In small-world: Opinion clusters might form regardless of initial heterogeneity

**For SA:** You need to test H4 across DIFFERENT network types:
```
Factorial design:
- Debate type: {heterogeneous, homogeneous}  
- Network type: {complete, random, small-world}
- 2 × 3 = 6 configurations

Question: Does debate type effect depend on network structure?
```

---

### Impact on All Other Hypotheses

**Every hypothesis about opinion dynamics depends on network structure!**

You cannot just pick "complete" and ignore the others. You need to either:

**Option A (Recommended):** 
- Use complete network as DEFAULT
- Report this as a LIMITATION
- In sensitivity analysis, show that results hold (or don't) for other networks

**Option B (Ideal but more work):**
- Test all hypotheses across all three network types
- Report which findings are robust to network choice
- Identify network-dependent effects

---

## What to Add to Your Protocol

### In Methods - Network Structure Section:

```
3.X.2 Network Structure

Agents are embedded in social networks representing debate interactions. 
Networks are debate-specific (no cross-debate connections) and exclude 
control group agents.

We implement three network structures controlled by the network_type parameter:

**Complete Network (Baseline):**
Each agent is connected to all other agents in their debate (excluding control).
This represents ideal deliberation where everyone can influence everyone else.
Network degree: n-1 where n is debate size.

**Random Network:**
Connections form probabilistically with parameter p (connection_probability).
Expected degree: (n-1) × p. This represents imperfect communication where 
some participants interact more than others.

**Small-World Network (Watts-Strogatz, 1998):**
Agents form a ring lattice with k nearest neighbors (default k=4), then 
with probability p_rewire (default 0.1) add random long-range connections.
This creates clustered groups with occasional bridges, representing realistic
social structure in deliberative settings.

All networks are STATIC - they do not change during simulation. This is a 
simplification but allows us to isolate opinion dynamics from network dynamics.

For our main analyses, we use the COMPLETE network structure as the baseline,
representing ideal deliberative conditions. Sensitivity analyses (Section 3.X)
test robustness across network types.
```

### In Sensitivity Analysis Section:

```
3.X.3 Network Structure Sensitivity

We test whether results are robust to network structure assumptions by:

1. **Within-type parameter variation:**
   - Random: connection_probability ∈ {0.3, 0.5, 0.7}
   - Small-world: k ∈ {2, 4, 6}, p_rewire ∈ {0.05, 0.1, 0.2}

2. **Across-type comparison:**
   - Run all hypotheses under Complete, Random, and Small-world networks
   - Report whether conclusions change with network structure

3. **Interaction with debate type (H4):**
   - Test whether heterogeneous vs homogeneous effect depends on network
   - 2×3 factorial: debate_type × network_type
```

---

## Action Items for You

### Immediate (This Week):

1. **Fix hardcoded parameters:**
   - Make k and p_rewire parameters in small-world
   - Verify connection_probability is a parameter

2. **Decide on directed vs undirected:**
   - Do you want symmetric influence?
   - If yes, fix random/small-world network creation

3. **Choose baseline network:**
   - Which network_type is your DEFAULT for main analyses?
   - Document this choice and justify it

4. **Update model elements chart:**
   - Add NET1-NET4 to parametric elements
   - Use my B2 table entry above

### For Protocol:

5. **Add network structure section** (use my template above)

6. **Add network to SA plan:**
   - Network type as non-parametric element to test
   - Network parameters (NET2-4) as parametric elements

7. **Update H4 to include network interaction:**
   - Does debate type effect hold across all network types?

---

## Tool Recommendation Revisited

Given that you're working with:
- Complex tables (model elements chart)
- Code snippets (GAMA code)
- Mathematical formulas
- Citations

**I strongly recommend: Visual Studio Code + Markdown extensions**

Why:
- Free and very stable
- Excellent code highlighting (syntax highlighting for GAMA too if you add extension)
- Great table support with extensions
- Version control integration (Git)
- Can edit your GAMA code AND documentation in same editor

**Setup:**
1. Download VS Code: https://code.visualstudio.com/
2. Install extensions:
   - "Markdown All in One"
   - "Markdown Table"
   - "Markdown Preview Enhanced"
3. Open your protocol folder as workspace
4. Edit .md files with live preview

**Alternative if VS Code feels too technical:** Obsidian (it's simpler but still very good for tables)

---

Let me know:
1. Which tool you want to try?
2. Do you need help fixing the directed network issue?
3. Should I help you add the network parameters to your full model elements chart?
