/* B3348 corr_population_covariance, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:103 */

data b3348a; do x=1 to 9; y=3*x; output; end; run;
proc corr data=b3348a outp=b3348b cov vardef=n noprint; var x y; run;
data b3348o; set b3348b; if _type_='COV' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set b3348o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3348 rows=' rows;
else do; set b3348o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND7_PASS=B3348';
else put 'ERROR: ROUND7_FAIL=B3348 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3348:; quit;
