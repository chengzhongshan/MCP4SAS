/* K4363 sort_ascii_case_order, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:79 */

data k4363a; length text $8; text='a'; value=4; output; text='A'; value=2*4; output; run;
proc sort data=k4363a out=k4363b sortseq=ascii; by text; run;
data k4363o; set k4363b(obs=1); actual=value; run;

data _null_; if 0 then set k4363o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4363 rows=' rows;
else do; set k4363o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND10_PASS=K4363';
else put 'ERROR: ROUND10_FAIL=K4363 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4363:; quit;
