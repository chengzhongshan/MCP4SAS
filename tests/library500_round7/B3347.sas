/* B3347 corr_population_covariance, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:103 */

data b3347a; do x=1 to 8; y=3*x; output; end; run;
proc corr data=b3347a outp=b3347b cov vardef=n noprint; var x y; run;
data b3347o; set b3347b; if _type_='COV' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set b3347o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3347 rows=' rows;
else do; set b3347o; if not missing(actual) and abs(actual-(15.75))<=1e-9*max(1,abs(15.75)) then put 'ROUND7_PASS=B3347';
else put 'ERROR: ROUND7_FAIL=B3347 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3347:; quit;
