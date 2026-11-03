/* R954 macro_local_scope, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:66 */

%let r954v=77;
%macro r954m(); %local r954v; %let r954v=5;
data r954a; inner=&r954v; run;
%mend; %r954m();
data r954o; set r954a; actual=inner+&r954v; run;
%symdel r954v; %sysmacdelete r954m;

data _null_; if 0 then set r954o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R954 rows=' rows;
else do; set r954o; if not missing(actual) and abs(actual-(82))<=1e-10*max(1,abs(82)) then put 'ROUND2_PASS=R954';
else put 'ERROR: ROUND2_FAIL=R954 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r954:; quit;
