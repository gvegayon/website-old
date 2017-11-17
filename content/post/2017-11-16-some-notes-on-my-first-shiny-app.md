---
title: Some notes on my first shiny app
author: George G. Vega Yon
date: '2017-11-16'
slug: some-notes-on-my-first-shiny-app
categories:
  - R
tags:
  - viz
  - rstats
---

Since there are plenty of examples out there telling you how to get started with shiny (like [Rstudio's](https://shiny.rstudio.com/tutorial/), or [Google](https://www.google.com/search?newwindow=1&ei=Og8OWpG4CYOUjwO9tZzABw&q=shiny+tutorial&oq=shiny+tutorial&gs_l=psy-ab.3..0i71k1l4.0.0.0.38217.0.0.0.0.0.0.0.0..0.0....0...1..64.psy-ab..0.0.0....0.v793tYPbUcw)), I will focus on telling some of the stuff that I did learned and may not be obvious at first, including some of the mistakes I made.

Before start, I just want to stress that I'm writing this after my first shiny app, you've been warned! Here it goes:

1.  __Use the "two-file" method__ Instead of putting everything, UI and Server, in a single `app.R` file, create two separate files `server.R` and `ui.R` (see [here](http://shiny.rstudio.com/articles/two-file.html)). This is not hard to figure out, but is not the first thing that you see when you create a shiny app from Rstudio. The reason why is very simple, as your project grows, you want to have it organized using several Rscripts rather than a single big R file that's called `app.R`. That's OK but not very friendly to maintain. This takes us to the next point.

2.  __Use separate R files for more complex functions__ If you have other functions that you would like to run with your app, either use the `global.R` script, which will be run automatically, or just source your file like `source("extra-functions.R")` (see [here](https://shiny.rstudio.com/articles/modules.html)). Again, this makes code maintenance easier.

3.  __Make sure all the packages that you need are installed__ You can either keep the source version of such packages as a sub directory, or follow a more simple approach such as using `require`, e.g.:
    ```r
    if (!require(somepackage)) {
      install.packages("somepackage")
      library(somepackage)
    }
    ```
    This is especially important when deploying shiny in a in-house server as the "shiny user" has to have access to those R packages. You can always try to install them globally too so that all users in the server have access to the required packages.
    
    More important, <font color="red"><b>make sure that you have `shiny` and `rmarkdown` installed and available system-wide!</b></font> I spent roughly half an hour figuring out why my shiny apps didn't started once I started the server in our machine.
    
4.  __Nested apps__ If you want to include several apps under the same folder in your `/srv/shiny-server` folder (which is where the shiny apps live), e.g. `my-apps`, avoid including `R` or `Rmd` files in that folder, shiny will try to run those as shiny apps and, for some reason that I'm not aware of, links that go from html pages in that folder to your sub directory apps will not work.
    
    For example, suppose that we have two apps, `shinyApp1` and `shinyApp2` and we want to keep those in the same folder `your-site`, and you have a nice front-end website allowing you to access to such apps with relative links in the form of `<a href="shinyApp1">Go to shinyApp1</a>`, you'll just need to __include the `index.html`__ of your website (which you can create with `rmarkdown`). The __following would be wrong__:
    ```
    +---/srv/shiny-server
    |   +---/you-site
    |       +---index.html
    |       +---index.Rmd    # THIS SHOULDN'T BE HERE!
    |       +---shinyApp1
    |           +---server.R
    |           +---ui.R
    |       +---shinyApp2
    |           +---server.R
    |           +---ui.R
    ```
    This would result in having a broken link in your `index.html` file. You should do this instead, remove the Rmd file from the `your-site` folder:
    ```
    +---/srv/shiny-server
    |   +---/you-site
    |       +---index.html
    |       +---shinyApp1
    |           +---server.R
    |           +---ui.R
    |       +---shinyApp2
    |           +---server.R
    |           +---ui.R
    ```
    This example was adapted from [Section 2.7.1](http://docs.rstudio.com/shiny-server/#host-a-directory-of-applications) from the Shiny's Admin guide.

5.  __Read about Reactivity__ This is a fundamental thing to understand in Shiny, moreover, the key function to review is `reactive`, which allows you to create intermediate points (reactive conductors) between your input and output data in the shiny app. Just to give you an idea, here is an (adapted) example that I find useful from the [shiny documentation](http://shiny.rstudio.com/articles/#reactivity):
    
    This will work
    ```r
    # A function that will be called from within the server
    fib <- function(n) ifelse(n<3, 1, fib(n-1)+fib(n-2))
    
    server <- function(input, output) {
      
      # Calling your fancy fib function, notice the
      #
      #     reactive({ ... })
      #
      # wrapper.
      currentFib         <- reactive({ fib(as.numeric(input$n)) })
    
      # You use it as a function later on.
      output$nthValue    <- renderText({ currentFib() })
      output$nthValueInv <- renderText({ 1 / currentFib() })
    }
    ```
    
    This won't work, since currentFib is not in the "reactive" world!
    ```r
    server <- function(input, output) {
      # Will give error
      currentFib      <- fib(as.numeric(input$n))
      output$nthValue <- renderText({ currentFib })
    }
    ```
    

For my next steps, I expect to be able to include a shiny app in the R packages `aphylo` (which is not on CRAN yet, but available [here](https://github.com/USCBiostats/aphylo)) and `rgexf` (which it is on [CRAN](https://cran.r-project.org/package=rgexf), but is currently on a major update [here](https://github.com/gvegayon/rgexf))

I recommend taking a look at [this section](https://bookdown.org/yihui/bookdown/web-pages-and-shiny-apps.html) from the [bookdown](https://bookdown.org/yihui/bookdown) that talks about how to include shiny apps within web pages.

Finally, if you are interested, you can take a look at the shiny app [here](https://gvegayon.shinyapps.io/predq/) and at the code [here](https://github.com/gvegayon/predq)