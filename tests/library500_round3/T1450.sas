/* T1450 macro_descending_loop, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:4 */

%macro t1450m(); %local i; data t1450a; %do i=11 %to 1 %by -1; x=&i; output; %end; run; %mend; %t1450m();
%sysmacdelete t1450m;
data t1450b; set t1450a; value=x*_n_; run;
proc sql; create table t1450o as select sum(value) as actual from t1450b; quit;

data _null_; if 0 then set t1450o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1450 rows=' rows;
else do; set t1450o; if not missing(actual) and abs(actual-(286))<=1e-10*max(1,abs(286)) then put 'ROUND3_PASS=T1450';
else put 'ERROR: ROUND3_FAIL=T1450 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1450:; quit;
