/* K4474 macro_indexed_odd_step_sum, N=5; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:441 */

%macro k4474m; %local i total; %let total=0;
%do i=1 %to %eval(2*5+1) %by 2; %let total=%eval(&total+&i); %end;
data k4474o; actual=&total; run; %mend; %k4474m; %sysmacdelete k4474m;

data _null_; if 0 then set k4474o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4474 rows=' rows;
else do; set k4474o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND10_PASS=K4474';
else put 'ERROR: ROUND10_FAIL=K4474 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4474:; quit;
