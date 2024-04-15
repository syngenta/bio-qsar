# Bio-QSAR 2.0

This repository includes data, code, and models from the publication: [Bio-QSARs 2.0: Unlocking a new level of predictive power for machine learning-based ecotoxicity predictions by exploiting chemical and biological information](https://www.sciencedirect.com/science/article/pii/S0160412024001934)

## Freshwater fish and invertebrate models

The second-generation Bio-QSAR models provided here allow the prediction of toxicity in freshwater fish and invertebrates. For information on development, use, and limitations, please see our associated publication.

Models were built using R version 4.1.3 and the packages tidyverse (version 2.0.0), gpboost (version 1.2.1), and SHAPforxgboost (version 0.1.3).

The script [Example.R](Example.R) includes examples on how to to make predictions with the models, how to apply the respective applicability domain, and how to analyse predictions locally using SHAP.

## Updated algorithm for multicollinearity correction

Additionally, we provide an updated R version of an algorithmic approach to correct datasets for multicollinearity that was presented in a [blog post](https://towardsdatascience.com/are-you-dropping-too-many-correlated-features-d1c96654abe6) by Brian Pietracatella. This approach is deemed to prevent the drop of too many variables and thus loose an unnecessarily large amount of information, while still eliminating multicollinearity. For more information, see our associated publication.

The function was built using R version 4.1.3 and the packages tidyverse (version 2.0.0) and caret (version 6.0.94).

The function [multicoll_sol.R](multicoll_sol.R) now allows for missing data running on pairwise complete observations. An example of usage can be found [here](https://github.com/syngenta/bio-qsar/blob/main/multicoll_example.R).
