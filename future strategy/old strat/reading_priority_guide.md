# ABM Literature: What to Read First

## The Situation

You've been hit with criticism about not knowing ABM validation literature. You need to:
1. Understand what you missed
2. Catch up quickly
3. Apply it to your work

## Reading Priority System

**🔴 CRITICAL (Read this week):**
- Essential for understanding what you're doing wrong
- Will directly change how you approach your protocol
- ~4-6 hours reading time total

**🟡 IMPORTANT (Read next week):**
- Provides depth and examples
- Helps you implement properly
- ~6-8 hours reading time total

**🟢 BACKGROUND (Read when you have time):**
- Theoretical foundations
- Nice to know but not urgent
- Ongoing learning

## 🔴 CRITICAL READINGS

### 1. Borgonovo et al. (2022) - The One You Already Have

**Citation:** Borgonovo, E., Pangallo, M., Rivkin, J., et al. (2022). Sensitivity analysis: A discipline coming of age. *Sensitivity Analysis in Practice*, 1-11.

**Why critical:** This is the paper you were criticized for not knowing. It's your North Star.

**What to focus on:**
- Table 1: The four SA goals (robustness, factor prioritization, interaction, direction)
- Figure 1: The SA workflow
- Section on parametric vs. non-parametric elements
- The "ABMs are different" argument

**How to read it:**
- First pass: Just read intro + Table 1 (30 min)
- Second pass: Read one section per SA goal (1-2 hours)
- Third pass: Annotate with notes on "how does this apply to MY model?" (1 hour)

**Action after reading:**
Map the four SA goals to your hypotheses (use framework document as template)

### 2. Railsback & Grimm (2019) - ABM Validation Bible

**Citation:** Railsback, S.F. & Grimm, V. (2019). *Agent-Based and Individual-Based Modeling: A Practical Introduction* (2nd ed.). Princeton University Press.

**What to read NOW:**
- Chapter 7: "Testing and Validating" (~30 pages)
- Chapter 23: "Parameterization and Calibration" (~25 pages)

**Why critical:** These chapters explain:
- What "validation" means for ABMs (it's not what you think)
- Pattern-oriented modeling
- How to calibrate properly
- Common mistakes (you're probably making them)

**How to read it:**
- Skim first for structure (20 min)
- Deep read on calibration section (1 hour)
- Make notes on "patterns" they mention - you need to identify patterns in YOUR data (30 min)

**Action after reading:**
List 5-7 empirical patterns your model should reproduce (beyond just MAE)

### 3. Ten Broeke et al. (2016) - Which SA Method When?

**Citation:** Ten Broeke, G., Van Voorn, G., & Ligtenberg, A. (2016). Which sensitivity analysis method should I use for my agent-based model? *JASSS*, 19(1), 5.

**Why critical:** You need to CHOOSE methods, not just "do SA."

**Length:** ~15 pages, very practical

**What to focus on:**
- Table 2: SA methods overview
- Figure 2: Decision tree for choosing methods
- Examples section - find one similar to your problem

**How to read it:**
- Read abstract + intro (15 min)
- Study Table 2 carefully (30 min)
- Read 2-3 method descriptions most relevant to you (45 min)

**Action after reading:**
For each hypothesis, write: "I will use [METHOD] because [REASON]"

### 4. Grimm et al. (2005) - Pattern-Oriented Modeling

**Citation:** Grimm, V., et al. (2005). Pattern-oriented modeling of agent-based complex systems: lessons from ecology. *Science*, 310(5750), 987-991.

**Why critical:** Short, foundational paper on HOW to validate ABMs

**Length:** 4 pages

**Key insight:** Match MULTIPLE patterns simultaneously to constrain your model

**How to read it:**
- Read the whole thing, it's short (30 min)
- Pay special attention to Figure 1 (the calibration strategy diagram)

**Action after reading:**
Revise your calibration targets from "minimize MAE" to "match these 5-7 patterns"

### 5. YOUR DOMAIN EXAMPLE (Ask Supervisor)

**You need ONE good example** of ABM used in your specific domain (meat consumption, deliberation, behavior change)

**Why critical:** Shows you what "good enough" looks like for publication in your field

**What to look for:**
- How did they specify their model?
- What SA did they do? (probably less than Borgonovo wants, but what's field standard?)
- How did they calibrate?
- What do their results sections look like?


## 🟡 IMPORTANT READINGS (Next Week)

### 6. Flache et al. (2017) - Social Influence Models

You already have this! But re-read it with new eyes:

**What to focus on NOW:**
- Section 4: "Empirical grounding" - how do they validate?
- Tables showing parameter values - where did they come from?
- Discussion of limitations

**New action:**
Compare their model specification to yours - are you as precise?


### 7. Windrum et al. (2007) - Empirical Validation

**Citation:** Windrum, P., Fagiolo, G., & Moneta, A. (2007). Empirical validation of agent-based models: Alternatives and prospects. *JASSS*, 10(2), 8.

**Why important:** Comprehensive overview of validation approaches

**What to read:**
- Section 3: "Indirect calibration approach" (your approach)
- Section 4: "Werker-Brenner approach" (pattern matching)
- Table 1: Validation methods comparison

**How to use it:**
Justify your validation choices using their framework


### 8. Saltelli et al. (2019) - Why Models Fail

**Citation:** Saltelli, A., et al. (2019). Why so many published sensitivity analyses are false: A systematic review of sensitivity analysis practices. *Environmental Modelling & Software*, 114, 29-39.

**Why important:** Cautionary tale about common SA mistakes

**What to focus on:**
- Table 2: Common pitfalls (check if you're making these)
- Section on "sensitivity auditing"

**Use case:** Learn what NOT to do


### 9. Lorscheid et al. (2012) - Replication for Robustness

**Citation:** Lorscheid, I., Heine, B.O., & Meyer, M. (2012). Opening the 'black box' of simulations: increased transparency and effective communication through the systematic design of experiments. *Computational and Mathematical Organization Theory*, 18(1), 22-62.

**Why important:** Explains why your "two random seeds" is hilariously insufficient

**What to read:**
- Section on experimental design
- Guidelines for replication runs


## 🟢 BACKGROUND (When You Have Time)

### Theoretical Foundations

10. **Epstein (1999):** Agent-based computational models and generative social science  
    *Why ABM at all? Theoretical justification*

11. **Dung (1995):** On the acceptability of arguments  
    *If you're using argumentation models*

12. **Mäs & Flache (2013):** Differentiation without distancing  
    *Social influence mechanisms - deeper theory*

### Advanced Validation

13. **Thiele et al. (2014):** Facilitating parameter estimation for ABMs  
    *When you want to get fancy with calibration*

14. **Lee et al. (2015):** The complexities of agent-based modeling output analysis  
    *When you're drowning in simulation data*


## Reading Strategy

### Week 1 Priority:
1. **Re-read Borgonovo** with the mindset of "how do I apply this?" (2 hours)
2. **Read Railsback & Grimm Chapters 7 & 23** (2 hours)
3. **Read Ten Broeke** decision tree paper (1.5 hours)
4. **Read Grimm pattern-oriented modeling** (30 min)
5. **Find and read domain example** (1-2 hours)

**Total: ~8 hours** - doable in a week alongside other work

### Week 2 Priority:
- Important readings (#6-9)
- Start applying to your own model specification

### Ongoing:
- Background readings as needed
- Papers your supervisor recommends

---

## How to Actually Read These Efficiently

### The 3-Pass Method

**Pass 1: Scout (10-15 min per paper)**
- Read abstract, intro, conclusion
- Look at figures and tables
- Decide: Is this relevant to my immediate problem?

**Pass 2: Targeted Read (30-60 min)**
- Read sections directly applicable to your issue
- Skip theoretical background you don't need yet
- Take notes on "Action Items" for your work

**Pass 3: Deep Dive (only if needed)**
- Read entire paper carefully
- Annotate with connections to your model
- Implement specific techniques


## Active Reading Checklist

For each critical paper, answer:

1. **What's the main insight?** (one sentence)
2. **What was I doing wrong?** (specific to your protocol)
3. **What should I do differently?** (concrete action)
4. **What can I quote in my methods section?** (to justify your approach)
5. **What questions do I have for supervisors?** (flag for discussion)

## Creating Your Own Reading Notes Document

Use this template:

```
Paper: [Title]
Date Read: [Date]
Relevance: [High/Medium/Low]

Main Insight:
[One paragraph summary]

What I Learned:
- [Key point 1]
- [Key point 2]
- [Key point 3]

Application to My Work:
- [Specific change 1]
- [Specific change 2]

Questions Raised:
- [Question for supervisor]
- [Question for myself to investigate]

Quotes to Use:
- "[Useful quote for methods section]" (p. X)
```

## When to Stop Reading and Start Doing

**Warning sign you're procrastinating:**
- Reading your 15th paper on SA methods
- Diving into advanced theory you don't need yet
- Using reading as an excuse to avoid revising your protocol

**Green light to stop and implement:**
- You can explain the four SA goals and how they apply to your hypotheses
- You can justify your method choices using the Ten Broeke decision tree
- You can describe pattern-oriented modeling in your own words
- You've identified 5-7 empirical patterns for calibration targets

**At that point:** Close the papers and start implementing. You can always read more later.

## Getting Help While Reading

**When you encounter something confusing:**

1. **Try for 15 minutes** to understand it yourself (Google, re-read, check examples)
2. **Write down specific question** - not "I don't get Sobol indices" but "Why do first-order and total-effect indices differ?"
3. **Ask your ABM supervisor** with context - "I'm reading Ten Broeke and I'm confused about [specific thing]"

**Don't:**
- Pretend you understand when you don't
- Skip over mathematical sections without trying
- Assume everything needs to be perfect before proceeding

## Reality Check

**You will NOT become an ABM expert in 2 weeks.**

**You CAN:**
- Understand what you were missing
- Implement a competent SA protocol
- Justify your choices using literature
- Communicate intelligently about limitations

**That's sufficient** for a thesis. Publication-level mastery comes with time and practice.

## Final Advice

1. **Read actively, not passively** - always ask "how does this apply to ME?"
2. **Take notes in YOUR OWN WORDS** - don't just highlight
3. **Implement as you go** - don't wait until you've read everything
4. **Ask questions early** - your supervisors expect you're learning
5. **It's okay to not know things** - you're a student, that's why you have supervisors

The point isn't to memorize these papers. The point is to understand the methodology well enough to apply it competently to your specific problem.

Now go read Borgonovo again, but this time with the framework documents I created as a guide. It'll make much more sense the second time through.
