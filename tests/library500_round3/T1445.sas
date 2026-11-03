/* T1445 macro_descending_loop, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:4 */

%macro t1445m(); %local i; data t1445a; %do i=6 %to 1 %by -1; x=&i; output; %end; run; %mend; %t1445m();
%sysmacdelete t1445m;
data t1445b; set t1445a; value=x*_n_; run;
proc sql; create table t1445o as select sum(value) as actual from t1445b; quit;

data _null_; if 0 then set t1445o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1445 rows=' rows;
else do; set t1445o; if not missing(actual) and abs(actual-(56))<=1e-10*max(1,abs(56)) then put 'ROUND3_PASS=T1445';
else put 'ERROR: ROUND3_FAIL=T1445 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1445:; quit;
