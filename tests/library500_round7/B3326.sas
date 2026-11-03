/* B3326 corr_kendall_monotonic, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:103 */

data b3326a; do x=1 to 7+2; y=x*x*x; output; end; run;
proc corr data=b3326a outk=b3326b kendall noprint; var x y; run;
data b3326o; set b3326b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set b3326o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3326 rows=' rows;
else do; set b3326o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND7_PASS=B3326';
else put 'ERROR: ROUND7_FAIL=B3326 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3326:; quit;
