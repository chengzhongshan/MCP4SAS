/* B3325 corr_kendall_monotonic, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:103 */

data b3325a; do x=1 to 6+2; y=x*x*x; output; end; run;
proc corr data=b3325a outk=b3325b kendall noprint; var x y; run;
data b3325o; set b3325b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set b3325o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3325 rows=' rows;
else do; set b3325o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND7_PASS=B3325';
else put 'ERROR: ROUND7_FAIL=B3325 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3325:; quit;
