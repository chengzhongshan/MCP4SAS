/* K4478 macro_indexed_odd_step_sum, N=9; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:441 */

%macro k4478m; %local i total; %let total=0;
%do i=1 %to %eval(2*9+1) %by 2; %let total=%eval(&total+&i); %end;
data k4478o; actual=&total; run; %mend; %k4478m; %sysmacdelete k4478m;

data _null_; if 0 then set k4478o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4478 rows=' rows;
else do; set k4478o; if not missing(actual) and abs(actual-(100))<=1e-9*max(1,abs(100)) then put 'ROUND10_PASS=K4478';
else put 'ERROR: ROUND10_FAIL=K4478 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4478:; quit;
