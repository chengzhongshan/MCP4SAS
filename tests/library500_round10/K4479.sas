/* K4479 macro_indexed_odd_step_sum, N=10; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:441 */

%macro k4479m; %local i total; %let total=0;
%do i=1 %to %eval(2*10+1) %by 2; %let total=%eval(&total+&i); %end;
data k4479o; actual=&total; run; %mend; %k4479m; %sysmacdelete k4479m;

data _null_; if 0 then set k4479o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4479 rows=' rows;
else do; set k4479o; if not missing(actual) and abs(actual-(121))<=1e-9*max(1,abs(121)) then put 'ROUND10_PASS=K4479';
else put 'ERROR: ROUND10_FAIL=K4479 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4479:; quit;
