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


