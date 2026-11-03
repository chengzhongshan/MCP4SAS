/* B3330 corr_kendall_monotonic, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:103 */

data b3330a; do x=1 to 11+2; y=x*x*x; output; end; run;
proc corr data=b3330a outk=b3330b kendall noprint; var x y; run;
data b3330o; set b3330b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set b3330o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3330 rows=' rows;
else do; set b3330o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND7_PASS=B3330';
else put 'ERROR: ROUND7_FAIL=B3330 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3330:; quit;
