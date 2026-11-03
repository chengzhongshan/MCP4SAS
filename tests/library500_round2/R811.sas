/* R811 compare_equal, N=2; source: SAS-Useful-Codes/Macros/SAS-macros-master/dumpsas.sas:279 */

data r811a; do x=1 to 2; value=x*x; output; end; run;
data r811b; set r811a; run;
proc compare base=r811a compare=r811b noprint; run;
data r811o; actual=&sysinfo; run;

data _null_; if 0 then set r811o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R811 rows=' rows;
else do; set r811o; if not missing(actual) and abs(actual-(0))<=1e-10*max(1,abs(0)) then put 'ROUND2_PASS=R811';
else put 'ERROR: ROUND2_FAIL=R811 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r811:; quit;
