/* T1447 macro_descending_loop, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:4 */

%macro t1447m(); %local i; data t1447a; %do i=8 %to 1 %by -1; x=&i; output; %end; run; %mend; %t1447m();
%sysmacdelete t1447m;
data t1447b; set t1447a; value=x*_n_; run;
proc sql; create table t1447o as select sum(value) as actual from t1447b; quit;

data _null_; if 0 then set t1447o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1447 rows=' rows;
else do; set t1447o; if not missing(actual) and abs(actual-(120))<=1e-10*max(1,abs(120)) then put 'ROUND3_PASS=T1447';
else put 'ERROR: ROUND3_FAIL=T1447 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1447:; quit;
