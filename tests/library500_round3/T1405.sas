/* T1405 macro_indirect_array, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:4 */

%macro t1405m(); %local i; %do i=1 %to 6; %local t1405v&i; %let t1405v&i=&i; %end;
data t1405o; actual=0; %do i=1 %to 6; actual=actual+&&t1405v&i; %end; run;
%mend; %t1405m(); %sysmacdelete t1405m;

data _null_; if 0 then set t1405o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1405 rows=' rows;
else do; set t1405o; if not missing(actual) and abs(actual-(21))<=1e-10*max(1,abs(21)) then put 'ROUND3_PASS=T1405';
else put 'ERROR: ROUND3_FAIL=T1405 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1405:; quit;
