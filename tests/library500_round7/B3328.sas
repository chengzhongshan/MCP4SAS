/* B3328 corr_kendall_monotonic, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:103 */

data b3328a; do x=1 to 9+2; y=x*x*x; output; end; run;
proc corr data=b3328a outk=b3328b kendall noprint; var x y; run;
data b3328o; set b3328b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set b3328o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3328 rows=' rows;
else do; set b3328o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND7_PASS=B3328';
else put 'ERROR: ROUND7_FAIL=B3328 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3328:; quit;
