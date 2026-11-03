/* R959 macro_local_scope, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:66 */

%let r959v=77;
%macro r959m(); %local r959v; %let r959v=10;
data r959a; inner=&r959v; run;
%mend; %r959m();
data r959o; set r959a; actual=inner+&r959v; run;
%symdel r959v; %sysmacdelete r959m;

data _null_; if 0 then set r959o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R959 rows=' rows;
else do; set r959o; if not missing(actual) and abs(actual-(87))<=1e-10*max(1,abs(87)) then put 'ROUND2_PASS=R959';
else put 'ERROR: ROUND2_FAIL=R959 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r959:; quit;
