/* R817 compare_equal, N=8; source: SAS-Useful-Codes/Macros/SAS-macros-master/dumpsas.sas:279 */

data r817a; do x=1 to 8; value=x*x; output; end; run;
data r817b; set r817a; run;
proc compare base=r817a compare=r817b noprint; run;
data r817o; actual=&sysinfo; run;

data _null_; if 0 then set r817o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R817 rows=' rows;
else do; set r817o; if not missing(actual) and abs(actual-(0))<=1e-10*max(1,abs(0)) then put 'ROUND2_PASS=R817';
else put 'ERROR: ROUND2_FAIL=R817 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r817:; quit;
