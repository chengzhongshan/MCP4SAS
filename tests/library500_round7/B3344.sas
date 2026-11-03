/* B3344 corr_population_covariance, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:103 */

data b3344a; do x=1 to 5; y=3*x; output; end; run;
proc corr data=b3344a outp=b3344b cov vardef=n noprint; var x y; run;
data b3344o; set b3344b; if _type_='COV' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set b3344o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3344 rows=' rows;
else do; set b3344o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND7_PASS=B3344';
else put 'ERROR: ROUND7_FAIL=B3344 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3344:; quit;
