/* K4471 macro_indexed_odd_step_sum, N=2; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:441 */

%macro k4471m; %local i total; %let total=0;
%do i=1 %to %eval(2*2+1) %by 2; %let total=%eval(&total+&i); %end;
data k4471o; actual=&total; run; %mend; %k4471m; %sysmacdelete k4471m;

data _null_; if 0 then set k4471o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4471 rows=' rows;
else do; set k4471o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND10_PASS=K4471';
else put 'ERROR: ROUND10_FAIL=K4471 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4471:; quit;
