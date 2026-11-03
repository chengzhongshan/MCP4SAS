/* T1443 macro_descending_loop, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:4 */

%macro t1443m(); %local i; data t1443a; %do i=4 %to 1 %by -1; x=&i; output; %end; run; %mend; %t1443m();
%sysmacdelete t1443m;
data t1443b; set t1443a; value=x*_n_; run;
proc sql; create table t1443o as select sum(value) as actual from t1443b; quit;

data _null_; if 0 then set t1443o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1443 rows=' rows;
else do; set t1443o; if not missing(actual) and abs(actual-(20))<=1e-10*max(1,abs(20)) then put 'ROUND3_PASS=T1443';
else put 'ERROR: ROUND3_FAIL=T1443 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1443:; quit;
