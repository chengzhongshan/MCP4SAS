/* T1441 macro_descending_loop, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:4 */

%macro t1441m(); %local i; data t1441a; %do i=2 %to 1 %by -1; x=&i; output; %end; run; %mend; %t1441m();
%sysmacdelete t1441m;
data t1441b; set t1441a; value=x*_n_; run;
proc sql; create table t1441o as select sum(value) as actual from t1441b; quit;

data _null_; if 0 then set t1441o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1441 rows=' rows;
else do; set t1441o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1441';
else put 'ERROR: ROUND3_FAIL=T1441 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1441:; quit;
