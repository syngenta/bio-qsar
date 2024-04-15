# Bio-QSAR

This repository includes data, code, and models from the publication: [Physiological variables in machine learning QSARs allow for both cross-chemical and cross-species predictions](https://www.sciencedirect.com/science/article/pii/S0147651323007546)

## Freshwater fish and invertebrate models

These Bio-QSAR models allow the prediction of toxicity in freshwater fish and invertebrates. For information on development, use, and limitations, please see our associated publication.

Models were built using R version 4.1.3 and the packages tidyverse (version 1.3.1), caret (version 6.0.91), and ranger (version 0.13.1).

The script [model_example.R](model_example.R) includes examples for fish and invertebrates.

## Algorithmic approach for multicollinearity correction

Here, we provide an R version of an approach to correct datasets for multicollinearity that was recently presented in a [blog post](https://towardsdatascience.com/are-you-dropping-too-many-correlated-features-d1c96654abe6) by Brian Pietracatella. This approach is deemed to prevent the drop of too many variables and thus loose an unnecessarily large amount of information, while still eliminating multicollinearity. For more information, see our associated publication.

The function was built using R version 4.1.3 and the packages tidyverse (version 1.3.1) and caret (version 6.0.91).

The script [multicoll_example.R](multicoll_example.R) includes an example.

The function returns a list with four elements:
* result$drop :  the features to drop according to the algorithm
* result$caret_before : the features to drop according to the caret function findCorrelation()
* result$caret_after : result of a second run of findCorrelation() after result$drop features have been dropped from the dataset; should be empty
* result$saved : features that have been saved by the algorithm
