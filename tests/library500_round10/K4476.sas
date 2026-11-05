/* K4476 macro_indexed_odd_step_sum, N=7; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:441 */

%macro k4476m; %local i total; %let total=0;
%do i=1 %to %eval(2*7+1) %by 2; %let total=%eval(&total+&i); %end;
data k4476o; actual=&total; run; %mend; %k4476m; %sysmacdelete k4476m;

data _null_; if 0 then set k4476o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4476 rows=' rows;
else do; set k4476o; if not missing(actual) and abs(actual-(64))<=1e-9*max(1,abs(64)) then put 'ROUND10_PASS=K4476';
else put 'ERROR: ROUND10_FAIL=K4476 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4476:; quit;
