/* R812 compare_equal, N=3; source: SAS-Useful-Codes/Macros/SAS-macros-master/dumpsas.sas:279 */

data r812a; do x=1 to 3; value=x*x; output; end; run;
data r812b; set r812a; run;
proc compare base=r812a compare=r812b noprint; run;
data r812o; actual=&sysinfo; run;

data _null_; if 0 then set r812o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R812 rows=' rows;
else do; set r812o; if not missing(actual) and abs(actual-(0))<=1e-10*max(1,abs(0)) then put 'ROUND2_PASS=R812';
else put 'ERROR: ROUND2_FAIL=R812 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r812:; quit;
