---
title: Working with sparse matrices in C++
author: George G. Vega Yon
date: '2018-01-16'
slug: working-with-sparse-matrices-in-cpp
categories:
  - R
tags:
  - rcpp
  - rstats
summary: "Sparse matrices in RcppArmadillo can be a very useful resource to work with, especially when you are dealing with social networks. Here I provide a couple of examples in which we can take advantage of their structure by using iterators."
---

```{r Setup, echo=FALSE}
knitr::opts_chunk$set(autodep = TRUE, cache = TRUE)
```

Working with sparse matrices is a big part of my day. Social networks are inherently sparse, so sparse matrices are the best buds you can get when representing large networks as adjacency matrices.[^large] As so, I usually find myself trying to take advantage of their structure as, contrasting dense matrices, we don't need to write nested `for(i...) for (j...)` loops to work with them, instead, sometimes all what we want is just to extract/work with its non-zero elements.

[^large]: It is important to notice that a lot of times using sparse matrices is not as useful as it sounds. Before embracing sparseness, think about whether your data needs it. Sparse networks can, sometimes, take you to the wrong place as when your matrix is _too dense_, neither your memory nor your computing time will get benefits from using sparse matrices.


About a year ago, while working on [netdiffuseR](https://github.com/USCCANA/netdiffuseR), I was struggling a bit to write down an efficient way of iterating through non-zero elements. Right after writing my own function to return the position of non-zero elements, I wrote [Dr Conrad Sanderson](http://conradsanderson.id.au/)--one of the masterminds behind armadillo--and learned that a nice solution for this was already included in armadillo, [matrix iterators](http://arma.sourceforge.net/docs.html#iterators_mat).

## A simple example

First off, to work with iterators for sparse matrices we will look at the simplest example: extracting positions and values from the matrix.

```{Rcpp simple-iterator, cache=TRUE}
#include <RcppArmadillo.h>
// [[Rcpp::depends(RcppArmadillo)]]

using namespace Rcpp;

// [[Rcpp::export]]
NumericMatrix sp_show_storage(arma::sp_mat x) {
  
  NumericMatrix ans(x.n_nonzero, 3u);
  int i = 0;
  for(arma::sp_mat::const_iterator it = x.begin(); it != x.end(); ++it) {
    
    ans(i, 0) = it.row(); // Row position
    ans(i, 1) = it.col(); // Col position
    ans(i++, 2) = *it;    // Value
    
  }
  
  // Adding colnames
  colnames(ans) = CharacterVector::create("row", "col", "val");
    
  return ans;
}

```

Here is a fake (not at all) sparse matrix of size 3x3 in which each of the non-zero elements `(i,j)` are in the form of `ij`.

```{r data-generating-process}

library(Matrix)
M <- matrix(0,nrow=3, ncol=3)
M[1,2] <- 12
M[2,1] <- 21
M[2,3] <- 23
M[3,2] <- 32
(M <- methods::as(M, "dgCMatrix"))
```

And here is what `sp_show_storage` returns from this sparse matrix.

```{r}
sp_show_storage(M)
```

## What about iterating through rows instead of columns?

The following lines of code create three functions, `sp_iterate`, `sp_row_iterate`, and `sp_t_iterate`, this is, a column-major iterator, a row-major iterator, and a pseudo row-major iterator (I first transpose the matrix, and then iterate using the column-major iterator), respectively.

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
  for (iter i = x.begin(); i != x.end(); i++)
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
  for (unsigned int i = 0; i < x.n_rows; i++)
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

```{r calling-the-functions}
data.frame(
  col_major  = sp_iterate(M),
  row_major  = sp_row_iterate(M),
  row_major2 = sp_t_iterate(M)
)
```

Now what about speed? 

```{r benchmark}
set.seed(1)
n <- 200
M <- methods::as(
  matrix(runif(n^2) < .001, nrow = n),
  "dgCMatrix"
)

microbenchmark::microbenchmark(
   sp_row_iterate(M),
   sp_t_iterate(M),
   times = 100, unit="relative"
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


