/* T1442 macro_descending_loop, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:4 */

%macro t1442m(); %local i; data t1442a; %do i=3 %to 1 %by -1; x=&i; output; %end; run; %mend; %t1442m();
%sysmacdelete t1442m;
data t1442b; set t1442a; value=x*_n_; run;
proc sql; create table t1442o as select sum(value) as actual from t1442b; quit;

data _null_; if 0 then set t1442o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1442 rows=' rows;
else do; set t1442o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1442';
else put 'ERROR: ROUND3_FAIL=T1442 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1442:; quit;
