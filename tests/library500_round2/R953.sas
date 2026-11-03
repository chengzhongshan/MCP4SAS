/* R953 macro_local_scope, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:66 */

%let r953v=77;
%macro r953m(); %local r953v; %let r953v=4;
data r953a; inner=&r953v; run;
%mend; %r953m();
data r953o; set r953a; actual=inner+&r953v; run;
%symdel r953v; %sysmacdelete r953m;

data _null_; if 0 then set r953o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R953 rows=' rows;
else do; set r953o; if not missing(actual) and abs(actual-(81))<=1e-10*max(1,abs(81)) then put 'ROUND2_PASS=R953';
else put 'ERROR: ROUND2_FAIL=R953 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r953:; quit;
