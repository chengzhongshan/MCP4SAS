/* B3342 corr_population_covariance, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:103 */

data b3342a; do x=1 to 3; y=3*x; output; end; run;
proc corr data=b3342a outp=b3342b cov vardef=n noprint; var x y; run;
data b3342o; set b3342b; if _type_='COV' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set b3342o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3342 rows=' rows;
else do; set b3342o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND7_PASS=B3342';
else put 'ERROR: ROUND7_FAIL=B3342 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3342:; quit;
