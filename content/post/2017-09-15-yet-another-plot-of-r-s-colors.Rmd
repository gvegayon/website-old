---
title: "Yet another plot of R's colors()"
author: George G. Vega Yon
date: '2017-09-15'
categories:
  - R
tags:
  - r
  - rstats
slug: yet-another-plot-of-r-s-colors
summary: "Just another matrix with the colors()'s colors"
---

```{r, echo=FALSE}
knitr::opts_chunk$set(cache = TRUE)
```

I know there are plenty of these online, but I just thought about having my own for quick reference...

```{r fancy-colors, out.height='800px', fig.width=8, fig.height=8}
ncols <- ceiling(sqrt(length(colors())))^2
dat <- matrix(1:ncols, sqrt(ncols))
image(dat, col = colors()[1:ncols])
pos <- seq(0, 1, length.out = sqrt(ncols))
pos <- lapply(pos, function(x) cbind(x, pos))
pos <- do.call(rbind, pos)

ncols <- length(colors())
text(x=pos[1:ncols,2], y=pos[1:ncols,1], labels = 1:ncols, cex=.75, srt=60)
```

