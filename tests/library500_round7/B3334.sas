/* B3334 corr_partial_control, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:103 */

data b3334a; do j=1 to 5; z=mod(j,2); x=-j; y=2*x+3*z; output; x=j; y=2*x+3*z; output; end; run;
proc corr data=b3334a outp=b3334b noprint; var x y; partial z; run;
data b3334o; set b3334b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set b3334o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3334 rows=' rows;
else do; set b3334o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND7_PASS=B3334';
else put 'ERROR: ROUND7_FAIL=B3334 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3334:; quit;
