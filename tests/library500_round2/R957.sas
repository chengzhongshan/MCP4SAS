/* R957 macro_local_scope, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:66 */

%let r957v=77;
%macro r957m(); %local r957v; %let r957v=8;
data r957a; inner=&r957v; run;
%mend; %r957m();
data r957o; set r957a; actual=inner+&r957v; run;
%symdel r957v; %sysmacdelete r957m;

data _null_; if 0 then set r957o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R957 rows=' rows;
else do; set r957o; if not missing(actual) and abs(actual-(85))<=1e-10*max(1,abs(85)) then put 'ROUND2_PASS=R957';
else put 'ERROR: ROUND2_FAIL=R957 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r957:; quit;
