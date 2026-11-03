/* T1410 macro_indirect_array, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:4 */

%macro t1410m(); %local i; %do i=1 %to 11; %local t1410v&i; %let t1410v&i=&i; %end;
data t1410o; actual=0; %do i=1 %to 11; actual=actual+&&t1410v&i; %end; run;
%mend; %t1410m(); %sysmacdelete t1410m;

data _null_; if 0 then set t1410o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1410 rows=' rows;
else do; set t1410o; if not missing(actual) and abs(actual-(66))<=1e-10*max(1,abs(66)) then put 'ROUND3_PASS=T1410';
else put 'ERROR: ROUND3_FAIL=T1410 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1410:; quit;
