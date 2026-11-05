/* K4412 contents_variable_position_checksum, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3099 */

data k4412a; array values{*} value1-value3; run;
proc contents data=k4412a out=k4412b noprint; run;
proc sql; create table k4412o as select sum(varnum) as actual from k4412b; quit;

data _null_; if 0 then set k4412o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4412 rows=' rows;
else do; set k4412o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND10_PASS=K4412';
else put 'ERROR: ROUND10_FAIL=K4412 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4412:; quit;
