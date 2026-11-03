/* B3322 corr_kendall_monotonic, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:103 */

data b3322a; do x=1 to 3+2; y=x*x*x; output; end; run;
proc corr data=b3322a outk=b3322b kendall noprint; var x y; run;
data b3322o; set b3322b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set b3322o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3322 rows=' rows;
else do; set b3322o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND7_PASS=B3322';
else put 'ERROR: ROUND7_FAIL=B3322 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3322:; quit;
