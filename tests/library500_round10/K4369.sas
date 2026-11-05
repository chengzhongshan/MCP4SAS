/* K4369 sort_ascii_case_order, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:79 */

data k4369a; length text $8; text='a'; value=10; output; text='A'; value=2*10; output; run;
proc sort data=k4369a out=k4369b sortseq=ascii; by text; run;
data k4369o; set k4369b(obs=1); actual=value; run;

data _null_; if 0 then set k4369o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4369 rows=' rows;
else do; set k4369o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND10_PASS=K4369';
else put 'ERROR: ROUND10_FAIL=K4369 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4369:; quit;
