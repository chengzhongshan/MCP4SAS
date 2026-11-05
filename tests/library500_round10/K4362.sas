/* K4362 sort_ascii_case_order, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:79 */

data k4362a; length text $8; text='a'; value=3; output; text='A'; value=2*3; output; run;
proc sort data=k4362a out=k4362b sortseq=ascii; by text; run;
data k4362o; set k4362b(obs=1); actual=value; run;

data _null_; if 0 then set k4362o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4362 rows=' rows;
else do; set k4362o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND10_PASS=K4362';
else put 'ERROR: ROUND10_FAIL=K4362 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4362:; quit;
