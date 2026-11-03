/* T1444 macro_descending_loop, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:4 */

%macro t1444m(); %local i; data t1444a; %do i=5 %to 1 %by -1; x=&i; output; %end; run; %mend; %t1444m();
%sysmacdelete t1444m;
data t1444b; set t1444a; value=x*_n_; run;
proc sql; create table t1444o as select sum(value) as actual from t1444b; quit;

data _null_; if 0 then set t1444o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1444 rows=' rows;
else do; set t1444o; if not missing(actual) and abs(actual-(35))<=1e-10*max(1,abs(35)) then put 'ROUND3_PASS=T1444';
else put 'ERROR: ROUND3_FAIL=T1444 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1444:; quit;
