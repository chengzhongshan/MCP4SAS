/* R819 compare_equal, N=10; source: SAS-Useful-Codes/Macros/SAS-macros-master/dumpsas.sas:279 */

data r819a; do x=1 to 10; value=x*x; output; end; run;
data r819b; set r819a; run;
proc compare base=r819a compare=r819b noprint; run;
data r819o; actual=&sysinfo; run;

data _null_; if 0 then set r819o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R819 rows=' rows;
else do; set r819o; if not missing(actual) and abs(actual-(0))<=1e-10*max(1,abs(0)) then put 'ROUND2_PASS=R819';
else put 'ERROR: ROUND2_FAIL=R819 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r819:; quit;
