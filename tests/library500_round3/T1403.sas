/* T1403 macro_indirect_array, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:4 */

%macro t1403m(); %local i; %do i=1 %to 4; %local t1403v&i; %let t1403v&i=&i; %end;
data t1403o; actual=0; %do i=1 %to 4; actual=actual+&&t1403v&i; %end; run;
%mend; %t1403m(); %sysmacdelete t1403m;

data _null_; if 0 then set t1403o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1403 rows=' rows;
else do; set t1403o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1403';
else put 'ERROR: ROUND3_FAIL=T1403 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1403:; quit;
