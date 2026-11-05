/* K4419 contents_variable_position_checksum, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3099 */

data k4419a; array values{*} value1-value10; run;
proc contents data=k4419a out=k4419b noprint; run;
proc sql; create table k4419o as select sum(varnum) as actual from k4419b; quit;

data _null_; if 0 then set k4419o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4419 rows=' rows;
else do; set k4419o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND10_PASS=K4419';
else put 'ERROR: ROUND10_FAIL=K4419 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4419:; quit;
