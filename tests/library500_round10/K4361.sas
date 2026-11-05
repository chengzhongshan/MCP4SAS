/* K4361 sort_ascii_case_order, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:79 */

data k4361a; length text $8; text='a'; value=2; output; text='A'; value=2*2; output; run;
proc sort data=k4361a out=k4361b sortseq=ascii; by text; run;
data k4361o; set k4361b(obs=1); actual=value; run;

data _null_; if 0 then set k4361o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4361 rows=' rows;
else do; set k4361o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND10_PASS=K4361';
else put 'ERROR: ROUND10_FAIL=K4361 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4361:; quit;
