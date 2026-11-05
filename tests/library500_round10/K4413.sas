/* K4413 contents_variable_position_checksum, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3099 */

data k4413a; array values{*} value1-value4; run;
proc contents data=k4413a out=k4413b noprint; run;
proc sql; create table k4413o as select sum(varnum) as actual from k4413b; quit;

data _null_; if 0 then set k4413o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4413 rows=' rows;
else do; set k4413o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND10_PASS=K4413';
else put 'ERROR: ROUND10_FAIL=K4413 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4413:; quit;
