/* T1427 symputx_local_scope, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/automate_proc_http_by_passing_the_requirement_of_cookie.sas:30 */

%let t1427value=77;
%macro t1427m(); %local t1427value; data _null_; call symputx('t1427value',8,'l'); run;
data t1427a; inner=&t1427value; run; %mend; %t1427m();
data t1427o; set t1427a; actual=inner+&t1427value; run;
%symdel t1427value; %sysmacdelete t1427m;

data _null_; if 0 then set t1427o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1427 rows=' rows;
else do; set t1427o; if not missing(actual) and abs(actual-(85))<=1e-10*max(1,abs(85)) then put 'ROUND3_PASS=T1427';
else put 'ERROR: ROUND3_FAIL=T1427 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1427:; quit;
