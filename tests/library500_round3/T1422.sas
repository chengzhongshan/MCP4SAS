/* T1422 symputx_local_scope, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/automate_proc_http_by_passing_the_requirement_of_cookie.sas:30 */

%let t1422value=77;
%macro t1422m(); %local t1422value; data _null_; call symputx('t1422value',3,'l'); run;
data t1422a; inner=&t1422value; run; %mend; %t1422m();
data t1422o; set t1422a; actual=inner+&t1422value; run;
%symdel t1422value; %sysmacdelete t1422m;

data _null_; if 0 then set t1422o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1422 rows=' rows;
else do; set t1422o; if not missing(actual) and abs(actual-(80))<=1e-10*max(1,abs(80)) then put 'ROUND3_PASS=T1422';
else put 'ERROR: ROUND3_FAIL=T1422 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1422:; quit;
