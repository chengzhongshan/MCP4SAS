/* B3341 corr_population_covariance, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:103 */

data b3341a; do x=1 to 2; y=3*x; output; end; run;
proc corr data=b3341a outp=b3341b cov vardef=n noprint; var x y; run;
data b3341o; set b3341b; if _type_='COV' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set b3341o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3341 rows=' rows;
else do; set b3341o; if not missing(actual) and abs(actual-(0.75))<=1e-9*max(1,abs(0.75)) then put 'ROUND7_PASS=B3341';
else put 'ERROR: ROUND7_FAIL=B3341 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3341:; quit;
