/* R815 compare_equal, N=6; source: SAS-Useful-Codes/Macros/SAS-macros-master/dumpsas.sas:279 */

data r815a; do x=1 to 6; value=x*x; output; end; run;
data r815b; set r815a; run;
proc compare base=r815a compare=r815b noprint; run;
data r815o; actual=&sysinfo; run;

data _null_; if 0 then set r815o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R815 rows=' rows;
else do; set r815o; if not missing(actual) and abs(actual-(0))<=1e-10*max(1,abs(0)) then put 'ROUND2_PASS=R815';
else put 'ERROR: ROUND2_FAIL=R815 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r815:; quit;
