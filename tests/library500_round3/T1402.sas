/* T1402 macro_indirect_array, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:4 */

%macro t1402m(); %local i; %do i=1 %to 3; %local t1402v&i; %let t1402v&i=&i; %end;
data t1402o; actual=0; %do i=1 %to 3; actual=actual+&&t1402v&i; %end; run;
%mend; %t1402m(); %sysmacdelete t1402m;

data _null_; if 0 then set t1402o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1402 rows=' rows;
else do; set t1402o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1402';
else put 'ERROR: ROUND3_FAIL=T1402 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1402:; quit;
