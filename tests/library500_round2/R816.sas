/* R816 compare_equal, N=7; source: SAS-Useful-Codes/Macros/SAS-macros-master/dumpsas.sas:279 */

data r816a; do x=1 to 7; value=x*x; output; end; run;
data r816b; set r816a; run;
proc compare base=r816a compare=r816b noprint; run;
data r816o; actual=&sysinfo; run;

data _null_; if 0 then set r816o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R816 rows=' rows;
else do; set r816o; if not missing(actual) and abs(actual-(0))<=1e-10*max(1,abs(0)) then put 'ROUND2_PASS=R816';
else put 'ERROR: ROUND2_FAIL=R816 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r816:; quit;
