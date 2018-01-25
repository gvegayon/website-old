---
title: Model Decision Tree
author: George G. Vega Yon
date: '2017-11-13'
slug: model-decision-tree
categories:
  - Stats
tags: []
draft: true
---

```{r nicebox, dependson=-1}
if (!require(DiagrammeR)) {
  install.packages("DiagrammeR", repos = "https://cloud.r-project.org")
  library(DiagrammeR)
}

grViz("
digraph boxes_and_circles {
  # Defining models
  node [shape = box]
  
  # Common world
  ols [label='Linear Regression']
  probit [label=Probit]
  logit [label=Logit]
  tobit [label=Tobit]

  # Networks
  ERGM
  Siena
  tERGM

  # Decisions
  node [shape=diamond]
  isiid [label='Is iid']
  iscts [label='Is continuous']

  node [shape=plaintext]
  iid [label='Independent data']
  noiid [label='Not independent data']
  ctsdat [label='Continuous']
  disdat [label='Discrete']
  mixdat [label='Mixture']
  

  # Edges
  isiid -> iid [dir=none,label=Yes]
  iid -> iscts [dir=none]
  
  iscts -> ctsdat [label=Yes] 
  ctsdat -> ols
  
  iscts -> disdat [label=No]
  disdat -> {probit logit}

  iscts -> mixdat [label=Both]
  mixdat -> tobit
  

  isiid -> noiid [dir=none, label=No]
  noiid -> ERGM
  
}

  
      ")
```

