/* K4420 contents_variable_position_checksum, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3099 */

data k4420a; array values{*} value1-value11; run;
proc contents data=k4420a out=k4420b noprint; run;
proc sql; create table k4420o as select sum(varnum) as actual from k4420b; quit;

data _null_; if 0 then set k4420o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4420 rows=' rows;
else do; set k4420o; if not missing(actual) and abs(actual-(66))<=1e-9*max(1,abs(66)) then put 'ROUND10_PASS=K4420';
else put 'ERROR: ROUND10_FAIL=K4420 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4420:; quit;
