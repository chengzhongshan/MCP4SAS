/* R818 compare_equal, N=9; source: SAS-Useful-Codes/Macros/SAS-macros-master/dumpsas.sas:279 */

data r818a; do x=1 to 9; value=x*x; output; end; run;
data r818b; set r818a; run;
proc compare base=r818a compare=r818b noprint; run;
data r818o; actual=&sysinfo; run;

data _null_; if 0 then set r818o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R818 rows=' rows;
else do; set r818o; if not missing(actual) and abs(actual-(0))<=1e-10*max(1,abs(0)) then put 'ROUND2_PASS=R818';
else put 'ERROR: ROUND2_FAIL=R818 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r818:; quit;
