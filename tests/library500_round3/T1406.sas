/* T1406 macro_indirect_array, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:4 */

%macro t1406m(); %local i; %do i=1 %to 7; %local t1406v&i; %let t1406v&i=&i; %end;
data t1406o; actual=0; %do i=1 %to 7; actual=actual+&&t1406v&i; %end; run;
%mend; %t1406m(); %sysmacdelete t1406m;

data _null_; if 0 then set t1406o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1406 rows=' rows;
else do; set t1406o; if not missing(actual) and abs(actual-(28))<=1e-10*max(1,abs(28)) then put 'ROUND3_PASS=T1406';
else put 'ERROR: ROUND3_FAIL=T1406 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1406:; quit;
