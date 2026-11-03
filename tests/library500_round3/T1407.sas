/* T1407 macro_indirect_array, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:4 */

%macro t1407m(); %local i; %do i=1 %to 8; %local t1407v&i; %let t1407v&i=&i; %end;
data t1407o; actual=0; %do i=1 %to 8; actual=actual+&&t1407v&i; %end; run;
%mend; %t1407m(); %sysmacdelete t1407m;

data _null_; if 0 then set t1407o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1407 rows=' rows;
else do; set t1407o; if not missing(actual) and abs(actual-(36))<=1e-10*max(1,abs(36)) then put 'ROUND3_PASS=T1407';
else put 'ERROR: ROUND3_FAIL=T1407 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1407:; quit;
