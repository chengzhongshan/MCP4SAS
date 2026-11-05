/* K4414 contents_variable_position_checksum, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3099 */

data k4414a; array values{*} value1-value5; run;
proc contents data=k4414a out=k4414b noprint; run;
proc sql; create table k4414o as select sum(varnum) as actual from k4414b; quit;

data _null_; if 0 then set k4414o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4414 rows=' rows;
else do; set k4414o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND10_PASS=K4414';
else put 'ERROR: ROUND10_FAIL=K4414 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4414:; quit;
