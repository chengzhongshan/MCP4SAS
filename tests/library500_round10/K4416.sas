/* K4416 contents_variable_position_checksum, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3099 */

data k4416a; array values{*} value1-value7; run;
proc contents data=k4416a out=k4416b noprint; run;
proc sql; create table k4416o as select sum(varnum) as actual from k4416b; quit;

data _null_; if 0 then set k4416o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4416 rows=' rows;
else do; set k4416o; if not missing(actual) and abs(actual-(28))<=1e-9*max(1,abs(28)) then put 'ROUND10_PASS=K4416';
else put 'ERROR: ROUND10_FAIL=K4416 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4416:; quit;
