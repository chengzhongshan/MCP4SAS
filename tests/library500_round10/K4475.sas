/* K4475 macro_indexed_odd_step_sum, N=6; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:441 */

%macro k4475m; %local i total; %let total=0;
%do i=1 %to %eval(2*6+1) %by 2; %let total=%eval(&total+&i); %end;
data k4475o; actual=&total; run; %mend; %k4475m; %sysmacdelete k4475m;

data _null_; if 0 then set k4475o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4475 rows=' rows;
else do; set k4475o; if not missing(actual) and abs(actual-(49))<=1e-9*max(1,abs(49)) then put 'ROUND10_PASS=K4475';
else put 'ERROR: ROUND10_FAIL=K4475 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4475:; quit;
