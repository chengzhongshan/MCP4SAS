/* T1423 symputx_local_scope, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/automate_proc_http_by_passing_the_requirement_of_cookie.sas:30 */

%let t1423value=77;
%macro t1423m(); %local t1423value; data _null_; call symputx('t1423value',4,'l'); run;
data t1423a; inner=&t1423value; run; %mend; %t1423m();
data t1423o; set t1423a; actual=inner+&t1423value; run;
%symdel t1423value; %sysmacdelete t1423m;

data _null_; if 0 then set t1423o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1423 rows=' rows;
else do; set t1423o; if not missing(actual) and abs(actual-(81))<=1e-10*max(1,abs(81)) then put 'ROUND3_PASS=T1423';
else put 'ERROR: ROUND3_FAIL=T1423 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1423:; quit;
