/* B3349 corr_population_covariance, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:103 */

data b3349a; do x=1 to 10; y=3*x; output; end; run;
proc corr data=b3349a outp=b3349b cov vardef=n noprint; var x y; run;
data b3349o; set b3349b; if _type_='COV' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set b3349o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3349 rows=' rows;
else do; set b3349o; if not missing(actual) and abs(actual-(24.75))<=1e-9*max(1,abs(24.75)) then put 'ROUND7_PASS=B3349';
else put 'ERROR: ROUND7_FAIL=B3349 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3349:; quit;
