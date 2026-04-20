# used to write notes about meetings and document progress

# RDV Nicolas 1/12/25
+ discuter avec doctorante Jellel niveau de discuter de jeux de donnees, influence d'enfants
+ simulation debats -> verifier les transcripts de debats et audio // devrais etre traité fin décembre

+ premier mois
+ focus sur simulation et modèles basiques
+ discuter d'intégration BDI ou autres dans GAMA
+ Mardi 20/1/26 potentiellement rdv a Toulouse

# RDV Nicolas et Benoit Girard 2/12/25
+ focus sur modèles simples et compréhension sur comment simuler les débats
+ penser au projet SHIFT dans le futur, could recreate actual food choices / from Jan 26 onwards

# RDV Nicolas et Patrick 3/12
+ send introduction presentation to Nicolas
+ use surveys in debates (can you find similar values in generated values using models?) -> use attitude before and after, maybe think about using challenge question (possibility of accepting a challenge)
+ set up a GAMA model with a public repo

# RDV Nicolas, Sabrina, Thomas, Patrick 8/12
+ for GAMA model -> try and find optimal value across all debates
+ re-setup 3rd debate group (i.e. homogeneous - pro and con; heterogeneous - mix of pro and con; active control, own group_
+ send Flache et al. 2017 to Sabrina and Thomas
+ mail to all meeting monday 13-14h // follow up
+ follow up GAMA-model -> look into Taillandier et al 2021 paper for argument synthesis and dynamics inside of GAMA

# RDV Nicolas, Thomas, Patrick 15/12
+ discussed how to move forward with argumentation model
+ need to finish model and integrate with thomas data
+ managed to almost entirely correct the model (added in convergence cycles and more tracking features)
+ see if you can change how many agents are in debates (can be variable)

# RDV Nicolas, Thomas 5/1/26
+ wait for debate file for analysis
+ progress update on Thomas paper

# RDV Nicolas 7/1/26
+ TT sur orhis (a verifier)
+ Benoit a Jussieu 11h du mat
    + utiliser les premieres 80 observations pour chercher des regles (dans le cadre de SWIFT)
    + essayer de combiner resto/simul/programmation
+ find thesis ideas

# RDV Nicolas 8/1/26
+ Review of debates & analysis
+ recap of which debates I have to transcribe/analyse
+ Thomas -> how to integrate argument relations in attitude development

# RDV Nicolas 13/1/26
+ parlé de debats
    + utiliser *** pour le chat
    + need to review debates according to this
+ simulation
    + send to patrick, thomas, nicolas, sabrina meeting suggestion for modelling with arguments (Friday 16/1)
+ Servers
    + check Stephane
    + Christina (collegue)
+ TODO
    + consensus data output set in a pivot (think about a presentation)
    + CSV parser for visualization
    + debates
        + in total (across all debates) -> what parameter and method works best
        + for each debate -> which method and parameters minimizes MAE
    + Financement -> visé pour 18 mois, preparer une thès des sep-oct 26

# RDV Nicolas, Patrick, Thomas 16/1/26
+ Bipol logic problem ??? are there cases where bipol returns clustering (what rules does this work under? specific conditions?)
+ data -> filter by exp condition // to compare pro/anti population (for hetero and homo debates)
+ TODO
    + include control single agent deliberation (own debate no updating → theoretically there is no evolution)
    + GAMA try and consider -> implementing 5 subfactors
        + agents interact on one of 5 subfactor values
        + threshold vary for each subfator
        + why threshold value helps recreate actual data?
    + think about protocol, what kind of questions can we ask?
    + analysis, segment by exp condition (which model wins in a het/homo debate?)

# RDV Nicolas, Patrick 20/1/26
+ own thought: how od subfactors evolves throughout a debate // what can i do to track this?
+ python: currently linear regression // can filter datasets to compare by exp group
    + future -> treat factors as independen, how to suggest future analyses with current data?
+ other covariates that could influence prediction power? (look at csv e.g., age, education, # agents in a debate)
+ explorae email check
+ sign up for SFN
+ Mercer (sign up and check email)

# RDV Nicolas 23/1/26
+ linear regression is a good start
+ in the end: is simul or reg better at predicting?
+ metrics: MAE, var MAE, median MAE
+ GAMA: track subfactor evolution across debate
+ structure for protocol
    + linear regression for benchmark
    + gama simul (identify tendencies of which model wins, track and viz attitutde evolution)
    + argumentaton model (quality and importance of arguments impact on prediction)
+ thesis: reinforcement learning is possible
    + 3 diff levels (online exp, resto expe, real cantine)

# RDV Nicolas 27/1/26
+ protocol:
    + more clearly define objective, base on literature by Pigazzi (Dauphine)
    + debates with multiple dimensions -> complex debates (what kind of hypotheses could we make?)
    + prople are already in a debate so what could drive opinion change (use T1 subfactor to predict T2)
+ ADEM:
    + X plates of food served which can create food waste
    + 3 experimental levels (online, resto expe, real cantine)
    + perspective de politique publique
+ points:
    + weekly hour meetings (need to address)
    + meetings transcription in git
    + GAMA recode & R analysis

# RDV Nicolas 28/1/26
+ regression anal protocol
    + give examples of emerging phenomena that could arise through deliberaiton that are not explained by regression models (non-independent regression factors)
    + look for papers that describe such phenomena and declare that regression is too simple
+ objectives:
    + 3 levels (indiv debate, per debate, global)
    + e.g. H1: regression -> evolution of attitudes is "impacted" by number of agents, talking time, etc
    + H2: GAMA hypotheses…
+ could code model with/without moderator (as this could have an influence and is what happens with the actual data collection)
    + at each iteration (cycle within a debate) what is happening -> all agents speak to everyone, and everyone listens (opinions update based on all neighbors)
        + control agents use:
            + test attitudes without discussion
            + debate MAE (discussion impact)
            + difference between control and debate MAE - potentially the effect of discussion
    + improvement: one speaker and all receive this information (could promote more realistic dynamics)
        + ask Patrick → send summary message of discussion and suggest meeting
     
# RDV Nicolas et Julien 29/1
- Thomas a résumé les progrès sur son article
- Nicolas résumé et discussion vis a vis du modèle de prise de parole sur GAMA → commencer a integrer ceci

# RDV Nicolas 3/2/26
- the progress i am making so far is just fine and positive!
    - my suggestions and critical thinking is great
- medium term in the lab
    - i would be the reference in the lab for simulation so do not hesitate to ask as many questions as possible
    - 1-2 weeks in Toulouse to work with Patrick (rediscuss all together)
- Complex Systems conference on gama google groups
- to discuss tomorrow
    - more in depth gama learning
    - want to interact with the gama community (researchers / thesis students)
    - Do not hesitate to ask questions!
- GAMA code for speaking -> 1 person speaks, all listen and aggregate their opinion from speaking opinion (and neighbors?)
- OSF
    - start filling out protocol in OSF
    - important "hypotheses, method and how do we evaluate the results"
    
# RDV Nicolas 11/2/26
+ acknowledge the lack of literature in this domain, ask patrick for more
    + model spec is incomplete
    + sensitivity analysis is non-existent
+ how much sensitivity analysis is appropriate given the timeline?
    + need to discuss with Patrick as well
+ Need more feedback in general
    + based on your recommendations I will go back and send model spec in 1 week
    + Patrick model review, then pilot results, revise protocol with everyone
+ seminaire mardi pro
+ MISS ABMS

# RDV Nicolas, Thomas, Julien 12/2/26
+ filling in model elements (done 13/2)
+ send thomas protocol doc
+ Gabriella Pigozzi for ABM references

# RDV Nicolas & Patrick 18/2/26
+ individual parameters done / agents with fixed or variable parameters?
+ next step is homophily
+ Toulouse
    + prendre les billets
    + keep receipts
+ Data analysis in R
    + easiest debate
+ why does GA not show variations?
+ ODD protocol for modle communication

# RDV Nicolas, Thomas, Julien, Sabrina 19/2/26
+ argument mining
+ set up vpn tutorial for Nicolas

# RDV Nicolas et Patrick 9/3/26
+ hetero/homo (agents) -> change wording to be more clear
+ parameter distribution (in accordance with metric)
    + how do distributions evolve graphically?
+ homophily (radical network re-assign)
+ TEST
    + one speak to all (talking stick)
    + who takes the speaker role?
    + probability of speaking to each agent
+ Case when no_change in opinion
    + will allow for a baseline to be established
+ opinion change by anti
    + why is clustering change so high?
+ attitude change - agent level
    + anti/pro how do empirical change occur
+ fin du mois ADEM
+ Seminaire neuro-behavior 10/3
+ Giovanni Squillero politecnico di torino

# RDV Nicolas et Sylie 12/3/26
+ project with the idea of observing indiv & colelctive mouse society
+ start with ABM modelling to then test in the field
+ follow mice over lifetime?
+ mouse utopia (60s experiment)

# RDV Patrick 12/3/26
+ role de parole (global reflex)
+ comparing models instead of experiments, we start from the same starting point
    + could use particle swarm alg
+ openmole research group (GA)
+ action to talk to all
    + ask all other to update, taking into account only his own opinion
+ next week meeting -> thursday afternoon

# RDV Nicolas 14/3/26
+ draft summary quick check together
+ easter only the 3 or 6 or both
+ thesis email (theses suggested are mainly bio)
+ GAMA set up -> final gui test of no change and speaking mode

# RDV Nicolas & Patrick 17/3/26
+ ADEM c'est rate // trouver un autre financement
+ Nicolas extension for 3 months
+ no change condition
    + mae is not zero but pulled from csv
    + speaking model (implement and check)
+ arguments
    + thomas to send arugments to an ai, look into attack and defence relationships
+ meeting friday afternoon?
+ Recap:
    + re-run all exps
    + modify analysis for no_change
    + properly rename exps
    + issue how ot solve recent_speak
        + speaking requires more than max_cycles
        + could increase max cycles or accept that some debates might not converge

# RDV Patrick 19/3/26
+ recent_speech+str is saving now
+ presentation
    + do control agents change at all (in empirical csv)
    + in a debate how many people speak? (ask thomas)
+ convergence
    + check transcripts for how many people speak, normalize the time steps
    + look into direciton of change, do we predict too much change in the wrong direction or not?
+ Nicolas contact miss ABMS
+ patrick doesn't think the lab is an issue

# RDV Nicolas 23/3/26
+ what if i reduce the aount of cycles to see if it amounts to anything?
+ distribution of MAE for N rows in each model, vary by parameter for LHS

# RDV ADAM Poland for RatRect 24/3
+ met phd student Wiktoria and Dominica
+ small description of RatRec use and how to operate the program
+ Meeting to analyse WAV together!

# RDV Nicolas 25/3/26
+ TO implement
    + constriant for neutral zone
    + after remove filterin in R, remove_df_post_filter
+ check hp elitebook 840 g10
+ agenda
+ SVS -> check how much time I have, wait for nicolas feedback on summary and presentation
+ Thesis -> keep drafting ideas and moving
+ summary
    + we present these 3 models
+ GAMA
    + look at change in convergence threshold / re run and do analysis
+ prolong mission
    + nicolas, to do admin side, 2 week agro close in august
    + ask nicolas if it is obligatory from the 1-15 august
+ next mission -> still on veg consumption, how od people influence each other, try and connect Benoit Girard, Meritschel, Patrick, Sabrina, Nicolas
+ MISS ABMS, send email
+ ODD 
    + exhaustive, then LHS and then GA
    + mail to Nicolas, Patrick, Sabrina for when they are ready for feedback
    
# RDV Nicolas 1/4/26
+ agenda --> Emmanuelle (for prolongation: demande pour 4 mois sur financement HERMES)
+ Patrick rdv 7/4 
+ for 7/4
    + finish LHS & GA
    + peut etere convergence cycle changes
+ receive Nicolas summary feedback
+ Pres
    + transition to sustainable diets
    + modelling in ABM
    + be visual
    + present hypotheses
    
# RDV Nicolas & Patrick 7/4
+ presentation
    + be more positive on outlook
    + model motivation focus
    + reduce context a little
+ I am interested in behavioral change and opinion evolution
+ what is a mini public
+ DOCS GAMA
    + report issue for docs problem "" problem
    + see wiki and check if you can edit it

# RDV Nicolas & Sabrina 7/4/26
+ exp set up in June Crous, entry manipulation (time, composition of self-service area)
+ think abou thow to ask ppl their preferences without divulging info

# RDV Nicolas et Patrick 15/4/26
+ convergence_cycle could be a parameter?
+ need to start thinking about JASSS or PCI submission
+ think about an ODD summary for your paper
+ Empirical data critiques
++ on which parameters do we play for us to reach the level of empirical change in the ABM models?
+++ implies setting a fixed stopping cycle or number of speaking steps
++ why do some debates reach convergence under no change?
+++ could investigate why some really good and really bad debates deviate so much from the empirical changes
+++ given a specific set of params and a model, are there debates that are randomly better than no change or not?
+ need to redo label gen in GAMA (ensure it is static and consistent across batch experiments)
+ IT IS BETTER TO USE HOMOGENEOUS AGENTS THAN TO MAKE MISTAKES ABOUT ASSUMING AGENTS ARE HETEROGENEOUS
+ could use particle swarm algorithm with very low parameter values to test if there is a difference in mae

# RDV Nicolas, Thomas, Sabrina 16/4/26
+ mistral to see how many agents you can run on different machines
+ thomas echange de parloe --> can only extract who is speaking and the valence of arguments
+ TODO
++ need to work on model_comparison logic
++ GAMA region bounds, non-used parameters need to be zeroed out in GAMA so that they don't generate NAs
++ label generation rework in GAMA (set static creation so that it persists across lhs, ga, annealing)

