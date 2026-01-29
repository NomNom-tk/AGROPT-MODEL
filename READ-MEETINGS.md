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
        + 
