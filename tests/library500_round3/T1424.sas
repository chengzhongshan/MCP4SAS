/* T1424 symputx_local_scope, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/automate_proc_http_by_passing_the_requirement_of_cookie.sas:30 */

%let t1424value=77;
%macro t1424m(); %local t1424value; data _null_; call symputx('t1424value',5,'l'); run;
data t1424a; inner=&t1424value; run; %mend; %t1424m();
data t1424o; set t1424a; actual=inner+&t1424value; run;
%symdel t1424value; %sysmacdelete t1424m;

data _null_; if 0 then set t1424o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1424 rows=' rows;
else do; set t1424o; if not missing(actual) and abs(actual-(82))<=1e-10*max(1,abs(82)) then put 'ROUND3_PASS=T1424';
else put 'ERROR: ROUND3_FAIL=T1424 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1424:; quit;
