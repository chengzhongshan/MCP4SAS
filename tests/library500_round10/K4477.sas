/* K4477 macro_indexed_odd_step_sum, N=8; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:441 */

%macro k4477m; %local i total; %let total=0;
%do i=1 %to %eval(2*8+1) %by 2; %let total=%eval(&total+&i); %end;
data k4477o; actual=&total; run; %mend; %k4477m; %sysmacdelete k4477m;

data _null_; if 0 then set k4477o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4477 rows=' rows;
else do; set k4477o; if not missing(actual) and abs(actual-(81))<=1e-9*max(1,abs(81)) then put 'ROUND10_PASS=K4477';
else put 'ERROR: ROUND10_FAIL=K4477 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4477:; quit;
