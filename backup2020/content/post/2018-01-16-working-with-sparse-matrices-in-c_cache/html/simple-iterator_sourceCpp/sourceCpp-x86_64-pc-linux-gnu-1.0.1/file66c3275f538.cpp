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

