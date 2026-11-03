/* T1448 macro_descending_loop, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:4 */

%macro t1448m(); %local i; data t1448a; %do i=9 %to 1 %by -1; x=&i; output; %end; run; %mend; %t1448m();
%sysmacdelete t1448m;
data t1448b; set t1448a; value=x*_n_; run;
proc sql; create table t1448o as select sum(value) as actual from t1448b; quit;

data _null_; if 0 then set t1448o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1448 rows=' rows;
else do; set t1448o; if not missing(actual) and abs(actual-(165))<=1e-10*max(1,abs(165)) then put 'ROUND3_PASS=T1448';
else put 'ERROR: ROUND3_FAIL=T1448 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1448:; quit;
