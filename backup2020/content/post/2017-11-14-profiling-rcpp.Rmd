---
title: Profiling Rcpp
author: George G. Vega Yon
date: '2017-11-14'
slug: profiling-rcpp
draft: true
categories:
  - R
tags:
  - rcpp
  - r
  - rstats
---

```{r, echo=FALSE}
knitr::opts_chunk$set(cache = TRUE)
```

1.  Install libuwind
    ```shell
    $ wget http://download.savannah.nongnu.org/releases/libunwind/libunwind-1.2.tar.gz && \
        tar -xf libunwind-1.2.tar.gz && cd libunwind-1.2; \
        ./configure; sudo make; sudo make install
    ```

2.  Install [google-perftools](https://github.com/gperftools/gperftools)
    
    ```shell 
    $ git clone https://github.com/gperftools/gperftools
    $ 
    ```
