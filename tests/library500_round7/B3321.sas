/* B3321 corr_kendall_monotonic, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:103 */

data b3321a; do x=1 to 2+2; y=x*x*x; output; end; run;
proc corr data=b3321a outk=b3321b kendall noprint; var x y; run;
data b3321o; set b3321b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set b3321o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3321 rows=' rows;
else do; set b3321o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND7_PASS=B3321';
else put 'ERROR: ROUND7_FAIL=B3321 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3321:; quit;
