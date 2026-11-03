/* T1449 macro_descending_loop, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:4 */

%macro t1449m(); %local i; data t1449a; %do i=10 %to 1 %by -1; x=&i; output; %end; run; %mend; %t1449m();
%sysmacdelete t1449m;
data t1449b; set t1449a; value=x*_n_; run;
proc sql; create table t1449o as select sum(value) as actual from t1449b; quit;

data _null_; if 0 then set t1449o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1449 rows=' rows;
else do; set t1449o; if not missing(actual) and abs(actual-(220))<=1e-10*max(1,abs(220)) then put 'ROUND3_PASS=T1449';
else put 'ERROR: ROUND3_FAIL=T1449 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1449:; quit;
