/* T1429 symputx_local_scope, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/automate_proc_http_by_passing_the_requirement_of_cookie.sas:30 */

%let t1429value=77;
%macro t1429m(); %local t1429value; data _null_; call symputx('t1429value',10,'l'); run;
data t1429a; inner=&t1429value; run; %mend; %t1429m();
data t1429o; set t1429a; actual=inner+&t1429value; run;
%symdel t1429value; %sysmacdelete t1429m;

data _null_; if 0 then set t1429o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1429 rows=' rows;
else do; set t1429o; if not missing(actual) and abs(actual-(87))<=1e-10*max(1,abs(87)) then put 'ROUND3_PASS=T1429';
else put 'ERROR: ROUND3_FAIL=T1429 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1429:; quit;
