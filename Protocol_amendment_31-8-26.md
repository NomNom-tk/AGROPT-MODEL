# Protocol Amendment - H6 Specification
**Date:** 31/8/26
**Amendment number:** 1

## Changes

H6 was registered as: "Agent-based models upgraded with argumentation mechanisms alongside models of social influence are expected to yield more accurate and stable predictions of global attitude distributions (using MAE) than models only using social influence mechanisms." 

H6 is now amended to: "Agent-based models built with an argumentation mechanism (following Taillandier et al., 2021) are expected to yield more accurate and stable predictions of global attitude distributions (using MAE) than agent-based models using only social influence mechanisms."

The change is in the framing from augmentation (where the social influence models get an added argumentation mechanism) to a head-to-head comparison (the argumentation models are built on the same infrastructure as the social influence models and can be directly compared with social influence models).

## Rationale
The argumentation model (Taillandier et al., 2021) replaces the opinion-update mechanism of the social influence models instead of augmenting it. Agents interact with each other using a list of arguments instead of directly exchanging opinions. A head-to-head comparison of this methodology with models of social influence (inspired by Flache et al., 2017) is an appropriate test of whether the argumentation model can better explain the empirical behavior seen in the study by Dheilly et al. (unpublished). The registered wording implied integration rather than replacement, which does not reflect the planned implementation. 

## Impact on other registered components

No other hypotheses, decision rules, or analysis plans are affected.