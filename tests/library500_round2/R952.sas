/* R952 macro_local_scope, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:66 */

%let r952v=77;
%macro r952m(); %local r952v; %let r952v=3;
data r952a; inner=&r952v; run;
%mend; %r952m();
data r952o; set r952a; actual=inner+&r952v; run;
%symdel r952v; %sysmacdelete r952m;

data _null_; if 0 then set r952o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R952 rows=' rows;
else do; set r952o; if not missing(actual) and abs(actual-(80))<=1e-10*max(1,abs(80)) then put 'ROUND2_PASS=R952';
else put 'ERROR: ROUND2_FAIL=R952 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r952:; quit;
