/* R820 compare_equal, N=11; source: SAS-Useful-Codes/Macros/SAS-macros-master/dumpsas.sas:279 */

data r820a; do x=1 to 11; value=x*x; output; end; run;
data r820b; set r820a; run;
proc compare base=r820a compare=r820b noprint; run;
data r820o; actual=&sysinfo; run;

data _null_; if 0 then set r820o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R820 rows=' rows;
else do; set r820o; if not missing(actual) and abs(actual-(0))<=1e-10*max(1,abs(0)) then put 'ROUND2_PASS=R820';
else put 'ERROR: ROUND2_FAIL=R820 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r820:; quit;
