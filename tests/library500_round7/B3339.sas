/* B3339 corr_partial_control, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:103 */

data b3339a; do j=1 to 10; z=mod(j,2); x=-j; y=2*x+3*z; output; x=j; y=2*x+3*z; output; end; run;
proc corr data=b3339a outp=b3339b noprint; var x y; partial z; run;
data b3339o; set b3339b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set b3339o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3339 rows=' rows;
else do; set b3339o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND7_PASS=B3339';
else put 'ERROR: ROUND7_FAIL=B3339 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3339:; quit;
