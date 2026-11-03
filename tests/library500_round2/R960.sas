/* R960 macro_local_scope, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:66 */

%let r960v=77;
%macro r960m(); %local r960v; %let r960v=11;
data r960a; inner=&r960v; run;
%mend; %r960m();
data r960o; set r960a; actual=inner+&r960v; run;
%symdel r960v; %sysmacdelete r960m;

data _null_; if 0 then set r960o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R960 rows=' rows;
else do; set r960o; if not missing(actual) and abs(actual-(88))<=1e-10*max(1,abs(88)) then put 'ROUND2_PASS=R960';
else put 'ERROR: ROUND2_FAIL=R960 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r960:; quit;
