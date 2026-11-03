/* R813 compare_equal, N=4; source: SAS-Useful-Codes/Macros/SAS-macros-master/dumpsas.sas:279 */

data r813a; do x=1 to 4; value=x*x; output; end; run;
data r813b; set r813a; run;
proc compare base=r813a compare=r813b noprint; run;
data r813o; actual=&sysinfo; run;

data _null_; if 0 then set r813o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R813 rows=' rows;
else do; set r813o; if not missing(actual) and abs(actual-(0))<=1e-10*max(1,abs(0)) then put 'ROUND2_PASS=R813';
else put 'ERROR: ROUND2_FAIL=R813 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r813:; quit;
