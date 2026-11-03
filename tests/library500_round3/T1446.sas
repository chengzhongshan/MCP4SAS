/* T1446 macro_descending_loop, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:4 */

%macro t1446m(); %local i; data t1446a; %do i=7 %to 1 %by -1; x=&i; output; %end; run; %mend; %t1446m();
%sysmacdelete t1446m;
data t1446b; set t1446a; value=x*_n_; run;
proc sql; create table t1446o as select sum(value) as actual from t1446b; quit;

data _null_; if 0 then set t1446o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1446 rows=' rows;
else do; set t1446o; if not missing(actual) and abs(actual-(84))<=1e-10*max(1,abs(84)) then put 'ROUND3_PASS=T1446';
else put 'ERROR: ROUND3_FAIL=T1446 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1446:; quit;
