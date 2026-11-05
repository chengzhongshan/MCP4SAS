/* K4411 contents_variable_position_checksum, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3099 */

data k4411a; array values{*} value1-value2; run;
proc contents data=k4411a out=k4411b noprint; run;
proc sql; create table k4411o as select sum(varnum) as actual from k4411b; quit;

data _null_; if 0 then set k4411o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4411 rows=' rows;
else do; set k4411o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND10_PASS=K4411';
else put 'ERROR: ROUND10_FAIL=K4411 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4411:; quit;
