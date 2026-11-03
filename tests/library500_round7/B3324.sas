/* B3324 corr_kendall_monotonic, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:103 */

data b3324a; do x=1 to 5+2; y=x*x*x; output; end; run;
proc corr data=b3324a outk=b3324b kendall noprint; var x y; run;
data b3324o; set b3324b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set b3324o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3324 rows=' rows;
else do; set b3324o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND7_PASS=B3324';
else put 'ERROR: ROUND7_FAIL=B3324 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3324:; quit;
