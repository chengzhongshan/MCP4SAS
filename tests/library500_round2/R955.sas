/* R955 macro_local_scope, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:66 */

%let r955v=77;
%macro r955m(); %local r955v; %let r955v=6;
data r955a; inner=&r955v; run;
%mend; %r955m();
data r955o; set r955a; actual=inner+&r955v; run;
%symdel r955v; %sysmacdelete r955m;

data _null_; if 0 then set r955o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R955 rows=' rows;
else do; set r955o; if not missing(actual) and abs(actual-(83))<=1e-10*max(1,abs(83)) then put 'ROUND2_PASS=R955';
else put 'ERROR: ROUND2_FAIL=R955 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r955:; quit;
