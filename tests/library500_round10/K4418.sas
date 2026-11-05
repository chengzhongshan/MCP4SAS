/* K4418 contents_variable_position_checksum, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3099 */

data k4418a; array values{*} value1-value9; run;
proc contents data=k4418a out=k4418b noprint; run;
proc sql; create table k4418o as select sum(varnum) as actual from k4418b; quit;

data _null_; if 0 then set k4418o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4418 rows=' rows;
else do; set k4418o; if not missing(actual) and abs(actual-(45))<=1e-9*max(1,abs(45)) then put 'ROUND10_PASS=K4418';
else put 'ERROR: ROUND10_FAIL=K4418 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4418:; quit;
