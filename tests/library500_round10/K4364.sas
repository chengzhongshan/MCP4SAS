/* K4364 sort_ascii_case_order, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:79 */

data k4364a; length text $8; text='a'; value=5; output; text='A'; value=2*5; output; run;
proc sort data=k4364a out=k4364b sortseq=ascii; by text; run;
data k4364o; set k4364b(obs=1); actual=value; run;

data _null_; if 0 then set k4364o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4364 rows=' rows;
else do; set k4364o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND10_PASS=K4364';
else put 'ERROR: ROUND10_FAIL=K4364 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4364:; quit;
