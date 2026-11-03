/* B3327 corr_kendall_monotonic, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:103 */

data b3327a; do x=1 to 8+2; y=x*x*x; output; end; run;
proc corr data=b3327a outk=b3327b kendall noprint; var x y; run;
data b3327o; set b3327b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set b3327o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3327 rows=' rows;
else do; set b3327o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND7_PASS=B3327';
else put 'ERROR: ROUND7_FAIL=B3327 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3327:; quit;
