/* R958 macro_local_scope, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:66 */

%let r958v=77;
%macro r958m(); %local r958v; %let r958v=9;
data r958a; inner=&r958v; run;
%mend; %r958m();
data r958o; set r958a; actual=inner+&r958v; run;
%symdel r958v; %sysmacdelete r958m;

data _null_; if 0 then set r958o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R958 rows=' rows;
else do; set r958o; if not missing(actual) and abs(actual-(86))<=1e-10*max(1,abs(86)) then put 'ROUND2_PASS=R958';
else put 'ERROR: ROUND2_FAIL=R958 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r958:; quit;
