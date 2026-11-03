/* T1408 macro_indirect_array, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:4 */

%macro t1408m(); %local i; %do i=1 %to 9; %local t1408v&i; %let t1408v&i=&i; %end;
data t1408o; actual=0; %do i=1 %to 9; actual=actual+&&t1408v&i; %end; run;
%mend; %t1408m(); %sysmacdelete t1408m;

data _null_; if 0 then set t1408o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1408 rows=' rows;
else do; set t1408o; if not missing(actual) and abs(actual-(45))<=1e-10*max(1,abs(45)) then put 'ROUND3_PASS=T1408';
else put 'ERROR: ROUND3_FAIL=T1408 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1408:; quit;
