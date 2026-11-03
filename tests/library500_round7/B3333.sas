/* B3333 corr_partial_control, N=4; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:103 */

data b3333a; do j=1 to 4; z=mod(j,2); x=-j; y=2*x+3*z; output; x=j; y=2*x+3*z; output; end; run;
proc corr data=b3333a outp=b3333b noprint; var x y; partial z; run;
data b3333o; set b3333b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set b3333o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3333 rows=' rows;
else do; set b3333o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND7_PASS=B3333';
else put 'ERROR: ROUND7_FAIL=B3333 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3333:; quit;
