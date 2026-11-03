/* T1428 symputx_local_scope, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/automate_proc_http_by_passing_the_requirement_of_cookie.sas:30 */

%let t1428value=77;
%macro t1428m(); %local t1428value; data _null_; call symputx('t1428value',9,'l'); run;
data t1428a; inner=&t1428value; run; %mend; %t1428m();
data t1428o; set t1428a; actual=inner+&t1428value; run;
%symdel t1428value; %sysmacdelete t1428m;

data _null_; if 0 then set t1428o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1428 rows=' rows;
else do; set t1428o; if not missing(actual) and abs(actual-(86))<=1e-10*max(1,abs(86)) then put 'ROUND3_PASS=T1428';
else put 'ERROR: ROUND3_FAIL=T1428 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1428:; quit;
