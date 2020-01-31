---
title: Working with sparse matrices in C++ (part 2)
author: George G. Vega Yon
date: '2019-07-25'
slug: working-with-sparse-matrices-in-cpp-part2
categories:
  - R
tags:
  - rcpp
  - rstats
summary: "This is an update on the performance of sparse matrices using the C++ armadillo (with the Rcpp wrapper)."
draft: true
---

```{r Setup, echo=FALSE}
knitr::opts_chunk$set(autodep = TRUE, cache = TRUE)
```

Last time I talked about this, iterators in armadillo were fast only in the constext of colum-major access, since data is stored like that. Today, the developers of armadillo, [Dr Conrad Sanderson](http://conradsanderson.id.au/) and [Dr Ryan Curtin](http://www.ratml.org/), have work furiously on adding new features to the header-only library, which has lead me to update the results of a benchmark I wrote on 2018:

```{Rcpp creating-function, cache=TRUE}
#include <RcppArmadillo.h>
// [[Rcpp::depends(RcppArmadillo)]]

using namespace Rcpp;

// Column-major method iterator (default)
// [[Rcpp::export]]
arma::vec sp_iterate(arma::sp_mat x) {
  
  arma::vec ans(x.n_nonzero);
  
  typedef arma::sp_mat::const_iterator iter;
  int k = 0;
  for (iter i = x.begin(); i != x.end(); ++i)
    ans.at(k++) = *i;
  
  return ans;
}

// Sort-of row-major method iterator. For this to work, we first need to tell
// armadillo which row we would like to look at... this doesn't look nice.
// [[Rcpp::export]]
arma::vec sp_row_iterate(arma::sp_mat x) {
  
  arma::vec ans(x.n_nonzero);
  
  typedef arma::sp_mat::const_row_iterator iter;
  int k = 0;
  for (unsigned int i = 0; i < x.n_rows; ++i)
    for (iter j = x.begin_row(i); j != x.end_row(i); ++j)
      ans.at(k++) = *j;
  
  return ans;
}


// Another sort-of row-major method iterator. Now, instead of using
// `const_row_iterator`, we use `const_iterator` but transpose the matrix first
// [[Rcpp::export]]
arma::vec sp_t_iterate(arma::sp_mat x) {
  
  arma::vec ans(x.n_nonzero);
  arma::sp_mat z = x.t();
  
  int k = 0;
  typedef arma::sp_mat::const_iterator iter;
  for (iter i = z.begin(); i != z.end(); ++i)
    ans.at(k++) = *i;
  
  return ans;
}


```

And here is what we get from calling each of the functions:

```{r data-generating-process}

library(Matrix)
M <- matrix(0,nrow=3, ncol=3)
M[1,2] <- 12
M[2,1] <- 21
M[2,3] <- 23
M[3,2] <- 32
(M <- methods::as(M, "dgCMatrix"))
```

```{r calling-the-functions}
data.frame(
  col_major  = sp_iterate(M),
  row_major  = sp_row_iterate(M),
  row_major2 = sp_t_iterate(M)
)
```

Now what about speed? 

```{r benchmark, cache=TRUE}
library(Matrix)
set.seed(1)
n <- 1000
M <- methods::as(
  matrix(runif(n^2) < .001, nrow = n),
  "dgCMatrix"
)

microbenchmark::microbenchmark(
   sp_row_iterate(M),
   sp_t_iterate(M),
   times = 1000, unit="relative"
)
```

It turns out that `const_row_iterator` implementation is significantly slower because of how the data is stored. The `SpMat` object from `armadillo` uses the [Column-Major Order](https://en.wikipedia.org/wiki/Row-_and_column-major_order) method for storing the sparse matrix, which means that, whenever we want to iterate through columns this is as easy as just reading the values as they are stored. On the other hand, iterating through row-major order implies doing a somewhat exhaustive search of non-empty cells at each row, which eventually becomes computationally very inefficient.

For those of you who like looking at source code, you can take a look at the way the `const_row_iterator` are implemented [here](https://fossies.org/dox/armadillo-8.300.3/SpMat__iterators__meat_8hpp_source.html) starting line 392. Here is an extract from the code:

>
This is irritating because we don't know where the elements are in each
row.  What we will do is loop across all columns looking for elements in
row 0 (and add to our sum), then in row 1, and so forth, until we get to
the desired position.

I can't agree more with that!


