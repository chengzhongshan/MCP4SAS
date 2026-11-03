/* B3350 corr_population_covariance, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:103 */

data b3350a; do x=1 to 11; y=3*x; output; end; run;
proc corr data=b3350a outp=b3350b cov vardef=n noprint; var x y; run;
data b3350o; set b3350b; if _type_='COV' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set b3350o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3350 rows=' rows;
else do; set b3350o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND7_PASS=B3350';
else put 'ERROR: ROUND7_FAIL=B3350 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3350:; quit;
