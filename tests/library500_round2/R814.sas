/* R814 compare_equal, N=5; source: SAS-Useful-Codes/Macros/SAS-macros-master/dumpsas.sas:279 */

data r814a; do x=1 to 5; value=x*x; output; end; run;
data r814b; set r814a; run;
proc compare base=r814a compare=r814b noprint; run;
data r814o; actual=&sysinfo; run;

data _null_; if 0 then set r814o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R814 rows=' rows;
else do; set r814o; if not missing(actual) and abs(actual-(0))<=1e-10*max(1,abs(0)) then put 'ROUND2_PASS=R814';
else put 'ERROR: ROUND2_FAIL=R814 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r814:; quit;
