/* R956 macro_local_scope, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:66 */

%let r956v=77;
%macro r956m(); %local r956v; %let r956v=7;
data r956a; inner=&r956v; run;
%mend; %r956m();
data r956o; set r956a; actual=inner+&r956v; run;
%symdel r956v; %sysmacdelete r956m;

data _null_; if 0 then set r956o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R956 rows=' rows;
else do; set r956o; if not missing(actual) and abs(actual-(84))<=1e-10*max(1,abs(84)) then put 'ROUND2_PASS=R956';
else put 'ERROR: ROUND2_FAIL=R956 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r956:; quit;
