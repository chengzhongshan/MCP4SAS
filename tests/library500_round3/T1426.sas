/* T1426 symputx_local_scope, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/automate_proc_http_by_passing_the_requirement_of_cookie.sas:30 */

%let t1426value=77;
%macro t1426m(); %local t1426value; data _null_; call symputx('t1426value',7,'l'); run;
data t1426a; inner=&t1426value; run; %mend; %t1426m();
data t1426o; set t1426a; actual=inner+&t1426value; run;
%symdel t1426value; %sysmacdelete t1426m;

data _null_; if 0 then set t1426o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1426 rows=' rows;
else do; set t1426o; if not missing(actual) and abs(actual-(84))<=1e-10*max(1,abs(84)) then put 'ROUND3_PASS=T1426';
else put 'ERROR: ROUND3_FAIL=T1426 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1426:; quit;
