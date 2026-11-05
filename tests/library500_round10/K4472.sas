/* K4472 macro_indexed_odd_step_sum, N=3; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:441 */

%macro k4472m; %local i total; %let total=0;
%do i=1 %to %eval(2*3+1) %by 2; %let total=%eval(&total+&i); %end;
data k4472o; actual=&total; run; %mend; %k4472m; %sysmacdelete k4472m;

data _null_; if 0 then set k4472o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4472 rows=' rows;
else do; set k4472o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND10_PASS=K4472';
else put 'ERROR: ROUND10_FAIL=K4472 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4472:; quit;
