/* T1425 symputx_local_scope, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/automate_proc_http_by_passing_the_requirement_of_cookie.sas:30 */

%let t1425value=77;
%macro t1425m(); %local t1425value; data _null_; call symputx('t1425value',6,'l'); run;
data t1425a; inner=&t1425value; run; %mend; %t1425m();
data t1425o; set t1425a; actual=inner+&t1425value; run;
%symdel t1425value; %sysmacdelete t1425m;

data _null_; if 0 then set t1425o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1425 rows=' rows;
else do; set t1425o; if not missing(actual) and abs(actual-(83))<=1e-10*max(1,abs(83)) then put 'ROUND3_PASS=T1425';
else put 'ERROR: ROUND3_FAIL=T1425 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1425:; quit;
