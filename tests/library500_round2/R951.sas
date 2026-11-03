/* R951 macro_local_scope, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:66 */

%let r951v=77;
%macro r951m(); %local r951v; %let r951v=2;
data r951a; inner=&r951v; run;
%mend; %r951m();
data r951o; set r951a; actual=inner+&r951v; run;
%symdel r951v; %sysmacdelete r951m;

data _null_; if 0 then set r951o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R951 rows=' rows;
else do; set r951o; if not missing(actual) and abs(actual-(79))<=1e-10*max(1,abs(79)) then put 'ROUND2_PASS=R951';
else put 'ERROR: ROUND2_FAIL=R951 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r951:; quit;
