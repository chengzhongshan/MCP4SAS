/* K4480 macro_indexed_odd_step_sum, N=11; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:441 */

%macro k4480m; %local i total; %let total=0;
%do i=1 %to %eval(2*11+1) %by 2; %let total=%eval(&total+&i); %end;
data k4480o; actual=&total; run; %mend; %k4480m; %sysmacdelete k4480m;

data _null_; if 0 then set k4480o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4480 rows=' rows;
else do; set k4480o; if not missing(actual) and abs(actual-(144))<=1e-9*max(1,abs(144)) then put 'ROUND10_PASS=K4480';
else put 'ERROR: ROUND10_FAIL=K4480 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4480:; quit;
