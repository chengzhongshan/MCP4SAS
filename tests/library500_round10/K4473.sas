/* K4473 macro_indexed_odd_step_sum, N=4; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:441 */

%macro k4473m; %local i total; %let total=0;
%do i=1 %to %eval(2*4+1) %by 2; %let total=%eval(&total+&i); %end;
data k4473o; actual=&total; run; %mend; %k4473m; %sysmacdelete k4473m;

data _null_; if 0 then set k4473o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4473 rows=' rows;
else do; set k4473o; if not missing(actual) and abs(actual-(25))<=1e-9*max(1,abs(25)) then put 'ROUND10_PASS=K4473';
else put 'ERROR: ROUND10_FAIL=K4473 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4473:; quit;
