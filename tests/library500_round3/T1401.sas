/* T1401 macro_indirect_array, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:4 */

%macro t1401m(); %local i; %do i=1 %to 2; %local t1401v&i; %let t1401v&i=&i; %end;
data t1401o; actual=0; %do i=1 %to 2; actual=actual+&&t1401v&i; %end; run;
%mend; %t1401m(); %sysmacdelete t1401m;

data _null_; if 0 then set t1401o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1401 rows=' rows;
else do; set t1401o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND3_PASS=T1401';
else put 'ERROR: ROUND3_FAIL=T1401 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1401:; quit;
