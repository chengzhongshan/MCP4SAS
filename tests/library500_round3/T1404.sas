/* T1404 macro_indirect_array, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:4 */

%macro t1404m(); %local i; %do i=1 %to 5; %local t1404v&i; %let t1404v&i=&i; %end;
data t1404o; actual=0; %do i=1 %to 5; actual=actual+&&t1404v&i; %end; run;
%mend; %t1404m(); %sysmacdelete t1404m;

data _null_; if 0 then set t1404o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1404 rows=' rows;
else do; set t1404o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND3_PASS=T1404';
else put 'ERROR: ROUND3_FAIL=T1404 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1404:; quit;
