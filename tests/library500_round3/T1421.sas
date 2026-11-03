/* T1421 symputx_local_scope, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/automate_proc_http_by_passing_the_requirement_of_cookie.sas:30 */

%let t1421value=77;
%macro t1421m(); %local t1421value; data _null_; call symputx('t1421value',2,'l'); run;
data t1421a; inner=&t1421value; run; %mend; %t1421m();
data t1421o; set t1421a; actual=inner+&t1421value; run;
%symdel t1421value; %sysmacdelete t1421m;

data _null_; if 0 then set t1421o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1421 rows=' rows;
else do; set t1421o; if not missing(actual) and abs(actual-(79))<=1e-10*max(1,abs(79)) then put 'ROUND3_PASS=T1421';
else put 'ERROR: ROUND3_FAIL=T1421 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1421:; quit;
