---
title: Read viz attributes from GEXF files
author: George G. Vega Yon
date: '2017-11-27'
slug: read-viz-attributes-from-gexf-files
categories:
  - R
tags:
  - networks
  - r
  - rstats
  - viz
---

```{r, echo=FALSE}
knitr::opts_chunk$set(cache = TRUE)
```

So one of the new features that I've working on is processing viz attributes. In the [CRAN version of rgexf](https://cran.r-project.org/package=rgexf), the function `read.gexf` only reads in non-visual attributes and the graph structure itself, which is no longer true [as of today](https://github.com/gvegayon/rgexf/commit/39d24409c7c641a1e62bdf518ff8ca46ea6172b5) (at least for the static viz attributes, all the other dynamic features supported by GEXF will come in the future).

We start by loading the R packages and reading the "lesmiserables.gexf" file that is included in `rgexf`. We use the `gexf.to.igraph` function to coerce the `gexf` object to an object of class `igraph`

```{r reading, message=FALSE, warning=FALSE}
# Loading R packages
library(rgexf)
library(igraph)

# Reading and coercing into an igraph object
fn      <- system.file("gexf-graphs", "lesmiserables.gexf", package="rgexf")
gexf1   <- read.gexf(fn)
igraph1 <- gexf.to.igraph(gexf1)
```

Here comes the nice new feature. `read.gexf` and `gexf.to.igraph` take into account the visual attributes of the network, and we can use those with `plot.igraph` directly without us specifying them! The only changes that I do in the next code chunk are rescaling the vertex and labels sizes (igraph automatically changes scales, which messes a bit with what we read from the GEXF object), and setting the edges to be curved and labels to be black using the `sans` font family, and this is what we get

```{r igraph-plot}
# We set the mai = c(0,0,0,0) so we have more space for our plot
oldpar <- par(no.readonly = TRUE)
par(mai = rep(0,4))
plot(igraph1,
     vertex.size        = V(igraph1)$size/2,
     vertex.label.cex   = V(igraph1)$size/50,
     vertex.label.color = "black",
     edge.curved        = TRUE,
     vertex.label.family = "sans"
     )
par(oldpar)
```

And to make sure we are getting the same output, we can take a look at how the `plot.gexf` function draws our GEXF graph.

```{r gexf-plot}
plot(
  gexf1,
  copy.only = TRUE,
  dir       = "../../static/post/read-viz-attributes-from-gexf-files/viz"
  )
```

<iframe width ="100%" height="400" src="viz/index.html"></iframe>

As expected, the same result.



