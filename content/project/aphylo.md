+++
# Date this page was created.
date = "2016-04-27"

# Project title.
title = "aphylo: Statistical Inference of Annotated Phylogenetic Trees"

# Project summary to display on homepage.
summary = "The aphylo R package implements estimation and data imputation methods for Functional Annotations in Phylogenetic Trees."

# Optional image to display on homepage (relative to `static/img/` folder).
# image_preview = "boards.jpg"

# Tags: can be used for filtering projects.
# Example: `tags = ["machine-learning", "deep-learning"]`
tags = ["statistical-computing"]

# Optional external URL for project (replaces project detail page).
# external_link = "https://github.com/USCbiostats/aphylo"

# Does the project detail page use math formatting?
math = false

+++

The aphylo R package implements estimation and data imputation methods for Functional Annotations in Phylogenetic Trees. The core function consists on the computation of the log-likelihood of observing a given phylogenetic tree with functional annotation on its leafs, and probabilities associated to gain and loss of functionalities, including probabilities of experimental misclassification. Furthermore, the log-likelihood is computed using peeling algorithms, which required developing and implementing efficient algorithms for re-coding and preparing phylogenetic tree data so that can be used with the package. Finally, aphylo works smoothly with popular tools for analysis of phylogenetic data such as ape R package, "Analyses of Phylogenetics and Evolution".

More details [here](https://github.com/USCbiostats/aphylo).