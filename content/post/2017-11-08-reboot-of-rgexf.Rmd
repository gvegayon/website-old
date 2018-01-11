---
title: Reboot of rgexf
author: George G. Vega Yon
date: '2017-11-08'
slug: reboot-of-rgexf
categories:
  - R
tags:
  - r
  - rstats
  - networks
  - viz
summary: The [rgexf](https://github.com/gvegayon/rgexf) R package has been around a couple of years now, but without much going on on CRAN (my bad!). In this post I'll show how to use the new version (on development and soon the be shipped to [CRAN](https://cran.r-project.org/package=rgexf)) together with the [netdiffuseR](https://github.com/USCCANA/netdiffuseR) R package to visualize a random diffusion process.
---

```{r, echo=FALSE}
knitr::opts_chunk$set(cache = TRUE)
```

The [rgexf](https://github.com/gvegayon/rgexf) R package has been around a couple of years now, but without much going on on CRAN (my bad!). In this post I'll show how to use the new version (on development and soon the be shipped to [CRAN](https://cran.r-project.org/package=rgexf)) together with the [netdiffuseR](https://github.com/USCCANA/netdiffuseR) R package to visualize a random diffusion process.

```{r setup, echo=FALSE, message=FALSE, warning=FALSE}

knitr::opts_chunk$set(message = FALSE, warning = FALSE)

if (!dir.exists("reboot-of-rgexf/gexf"))
  dir.create("reboot-of-rgexf/gexf", recursive = TRUE)
```


First, we load all the packages that we will be using

```{r loading}
# Loading the relevant packages
library(igraph, quietly = TRUE)
library(rgexf, quietly = TRUE)
library(netdiffuseR, quietly = TRUE)
```

Next, we simulate a random diffusion network, in this case, a small-world network with 200 nodes spanning 20 time periods.

```{r simnet}
# A random diffusion network
set.seed(122)
net <- rdiffnet(n = 200, t=20, seed.graph = "small-world")
```

Now, we get the parameters ready, in this case, position using the function `layout_nicely` from the igraph package, and colors using the Time of Adoption (toa)

```{r params}
# Setting viz attributes
pos <- cbind(layout_nicely(diffnet_to_igraph(net)[[1]]), 0)

# Coloring according to time of adoption. White ones are not
# adopters.
col <- diffnet.toa(net)
col <- col/20
col <- colorRamp(blues9, alpha = TRUE)(col)
col[is.na(col[,1]),1:3] <- 255
col[,4] <- .5
```

Finally, we create the GEXF object and call the plot function. In this case we are using [gexf-js](https://github.com/raphv/gexf-js) (sigma-js will return in the future). Also, notice that we are only copying the files; the default behavior is to copy the files by setting `copy.only = TRUE` and start the server using the [servr](https://cran.r-project.org/package=servr). 


```{r gexf}
# Creating the gexf object
gf <- igraph.to.gexf(
  diffnet_to_igraph(net)[[1]],
  nodesVizAtt = list(
    color    = col,
    position = pos
    )
  )

# Plotting using gexf-js
plot(
  gf,
  edgeWidthFactor = .1,
  copy.only = TRUE,
  dir       = "../../static/post/reboot-of-rgexf/viz"
  )

```

You can take a look at resulting website [here](viz). 

## Session info

```{r}
devtools::session_info()
```

## Last updated

This post was last updated on 2017-11-13 to reflect a small change in `rgexf` that makes it easier to process colors and positions.