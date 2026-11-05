/* K4417 contents_variable_position_checksum, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3099 */

data k4417a; array values{*} value1-value8; run;
proc contents data=k4417a out=k4417b noprint; run;
proc sql; create table k4417o as select sum(varnum) as actual from k4417b; quit;

data _null_; if 0 then set k4417o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4417 rows=' rows;
else do; set k4417o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND10_PASS=K4417';
else put 'ERROR: ROUND10_FAIL=K4417 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4417:; quit;
