/* T1409 macro_indirect_array, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:4 */

%macro t1409m(); %local i; %do i=1 %to 10; %local t1409v&i; %let t1409v&i=&i; %end;
data t1409o; actual=0; %do i=1 %to 10; actual=actual+&&t1409v&i; %end; run;
%mend; %t1409m(); %sysmacdelete t1409m;

data _null_; if 0 then set t1409o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1409 rows=' rows;
else do; set t1409o; if not missing(actual) and abs(actual-(55))<=1e-10*max(1,abs(55)) then put 'ROUND3_PASS=T1409';
else put 'ERROR: ROUND3_FAIL=T1409 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1409:; quit;
