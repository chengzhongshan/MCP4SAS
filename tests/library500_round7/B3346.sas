/* B3346 corr_population_covariance, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:103 */

data b3346a; do x=1 to 7; y=3*x; output; end; run;
proc corr data=b3346a outp=b3346b cov vardef=n noprint; var x y; run;
data b3346o; set b3346b; if _type_='COV' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set b3346o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3346 rows=' rows;
else do; set b3346o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND7_PASS=B3346';
else put 'ERROR: ROUND7_FAIL=B3346 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3346:; quit;
