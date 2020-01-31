`.sourceCpp_1_DLLInfo` <- dyn.load('/home/vegayon/Documents/website/content/post/2018-01-16-working-with-sparse-matrices-in-c_cache/html/creating-function_sourceCpp/sourceCpp-x86_64-pc-linux-gnu-1.0.0/sourcecpp_241ea260954/sourceCpp_2.so')

sp_iterate <- Rcpp:::sourceCppFunction(function(x) {}, FALSE, `.sourceCpp_1_DLLInfo`, 'sourceCpp_1_sp_iterate')
sp_row_iterate <- Rcpp:::sourceCppFunction(function(x) {}, FALSE, `.sourceCpp_1_DLLInfo`, 'sourceCpp_1_sp_row_iterate')
sp_t_iterate <- Rcpp:::sourceCppFunction(function(x) {}, FALSE, `.sourceCpp_1_DLLInfo`, 'sourceCpp_1_sp_t_iterate')

rm(`.sourceCpp_1_DLLInfo`)
