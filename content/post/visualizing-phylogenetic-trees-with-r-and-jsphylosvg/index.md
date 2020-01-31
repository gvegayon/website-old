---
title: Visualizing Phylogenetic Trees with R and jsPhyloSVG
author: George G. Vega Yon
date: '2017-12-08'
slug: visualizing-phylogenetic-trees-with-r-and-jsphylosvg
categories:
  - R
tags:
  - r
  - rstats
  - viz
  - phylo
---

During the last year I've been working on a daily basis with [phylogenetic trees](../publication/aphylo/), objects that in graph jargon are called Directed Acyclic Graphs. While R does have some cool packages out there to visualize these--including [phylocanvas](https://zachcp.github.io/phylocanvas/) which looks great!--I wanted to tryout [jsPhyloSVG](http://www.jsphylosvg.com), and moreover, to learn how to use [htmlwidgets](http://www.htmlwidgets.org).

So, after a week-long process of playing with JavaScript, of which I had no prior knowledge (so thank you [W3shools](https://w3schools.com))!, and hours of head-scratching, I created this R package, [jsPhyloSVG](https://USCBiostats.github.io/jsPhyloSVG) that provides an htmlwidget for the library of the same name. An example follows


```{r, echo=FALSE}
knitr::opts_chunk$set(cache = TRUE)
```


```{r}
# I'll be using the ape package to simulate a tree
library(ape)
# You can get it from github USCBiostats/jsPhyloSVG
library(jsPhyloSVG)

# A random phylogenetic tree with 50 tips
tree <- rtree(50)

jsPhyloSVG(write.tree(tree))
```

You can take a look at the project repo [here](https://github.com/USCBiostats/jsPhyloSVG).
