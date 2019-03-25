---
title: Environments in R Rock
author: George G. Vega Yon
date: '2017-10-02'
slug: environments-in-r-rock
categories:
  - R
tags:
  - r
  - rstats
summary: "In this post I provide a short example in which default arguments are specified not in the function definition, but rather externally making use of environments. A _method_ that I've use recently used in [netdiffuseR](https://github.com/USCCANA/netdiffuseR)."
---

```{r, echo=FALSE}
knitr::opts_chunk$set(cache = TRUE)
```

Last week I found myself working on <a href="https://github.com/USCCANA/netdiffuseR" target="_blank">netdiffuseR</a> trying to establish nice defaults for some plotting functions with the following goals:

1.  Make the code easy to maintain: So if I need to change defaults I just change a few lines and that works for all plot functions,

2.  Make the code easy to see in the manual (help) file: So is easier to the user to focus on the main features of a plot rather than looking at a large description of a function with lots of parameters and lots of defaults, and

3.  Make the code hopefully efficient: Not that I care that much, but if I'm going to be passing arguments across functions, it better be efficient!

So, long story short, I came up with the following approach:

1.  Create a list of defaults included in the package: This is actually something that I've already seen in some other places, like for example <a href="https://github.com/igraph/rigraph/blob/665d71ebd40cdfe9b996a4f50c35d65b791e4102/R/par.R" target="_blank">igraph</a>, they have a couple of environments that set plotting defaults.

2.  Make a heavy use of the ellipsis! `...` So I can actually grab whatever the user passed through it, and later modify the arguments (I'll show this in an example)

3.  Use 1. to modify 2. at will... with environments!

While I'm not sure this is the most efficient way of doing this (and I'm pretty sure that I'm not the first person to do something like this), it works for what I'm doing right now. The following piece of code illustrates how this works.

This is a list of the defaults that we would like all the functions to have:

```{r defaults}
# This list holds the default parameters
defaults <- list(color="steelblue", add=FALSE)
```

This function is the one that sets the defaults, follow the comments to see how it works:

```{r set-defaults}
# This function sets the defaults giving the name of an object that holds the
# parameters... or at least should hold them!
set.defaults <- function(obj_name) {
  
  # Where was this function called from? This way we get
  # the parent frame (the environment from where the function was called)
  # this actually holds all the elements, but works as a reference, so no copy!
  env <- parent.frame()
  
  # Now we loop throught the defaults that I've specified
  # in -defaults-
  for (d in names(defaults))
    # If -d- hasn't been specified, then set it!
    if (!length(env[[obj_name]][[d]]))
      env[[obj_name]][[d]] <- defaults[[d]]
}
```

This is a function that illustrates how everything works together. So we can pass extra arguments with the ellipsis, we store them in a list called `dots` (I'm sure there must be a more efficient way of doing this, but it's OK for now :]), sets the defaults calling `set.defaults`, and returns the `dots` list:

```{r a-function}
f <- function(...) {
  
  # Getting the dots
  dots <- list(...)
  
  # Setting defaults
  set.defaults("dots")
  
  # Did we got them?
  return(dots)
}
```

Now let's see if it works!

```{r testing}
f()
f(color="green")
```

As expected, the first call of the function returns the default parameters. In the second call, since I specified `"green"`, the function `set.defaults` only set the argument `add`.

You can read more about environments in <a href="http://adv-r.had.co.nz/Environments.html" target="_blank">Hadley Wickham's Advance R</a>.