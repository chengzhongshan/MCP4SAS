/* T1430 symputx_local_scope, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/automate_proc_http_by_passing_the_requirement_of_cookie.sas:30 */

%let t1430value=77;
%macro t1430m(); %local t1430value; data _null_; call symputx('t1430value',11,'l'); run;
data t1430a; inner=&t1430value; run; %mend; %t1430m();
data t1430o; set t1430a; actual=inner+&t1430value; run;
%symdel t1430value; %sysmacdelete t1430m;

data _null_; if 0 then set t1430o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1430 rows=' rows;
else do; set t1430o; if not missing(actual) and abs(actual-(88))<=1e-10*max(1,abs(88)) then put 'ROUND3_PASS=T1430';
else put 'ERROR: ROUND3_FAIL=T1430 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1430:; quit;
