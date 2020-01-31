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



#include <Rcpp.h>
// sp_show_storage
NumericMatrix sp_show_storage(arma::sp_mat x);
RcppExport SEXP sourceCpp_1_sp_show_storage(SEXP xSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< arma::sp_mat >::type x(xSEXP);
    rcpp_result_gen = Rcpp::wrap(sp_show_storage(x));
    return rcpp_result_gen;
END_RCPP
}
