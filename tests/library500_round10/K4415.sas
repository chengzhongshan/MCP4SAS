/* K4415 contents_variable_position_checksum, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3099 */

data k4415a; array values{*} value1-value6; run;
proc contents data=k4415a out=k4415b noprint; run;
proc sql; create table k4415o as select sum(varnum) as actual from k4415b; quit;

data _null_; if 0 then set k4415o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4415 rows=' rows;
else do; set k4415o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND10_PASS=K4415';
else put 'ERROR: ROUND10_FAIL=K4415 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4415:; quit;
