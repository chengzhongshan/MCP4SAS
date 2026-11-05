/* K4368 sort_ascii_case_order, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:79 */

data k4368a; length text $8; text='a'; value=9; output; text='A'; value=2*9; output; run;
proc sort data=k4368a out=k4368b sortseq=ascii; by text; run;
data k4368o; set k4368b(obs=1); actual=value; run;

data _null_; if 0 then set k4368o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4368 rows=' rows;
else do; set k4368o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND10_PASS=K4368';
else put 'ERROR: ROUND10_FAIL=K4368 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4368:; quit;
