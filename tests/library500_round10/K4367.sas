/* K4367 sort_ascii_case_order, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:79 */

data k4367a; length text $8; text='a'; value=8; output; text='A'; value=2*8; output; run;
proc sort data=k4367a out=k4367b sortseq=ascii; by text; run;
data k4367o; set k4367b(obs=1); actual=value; run;

data _null_; if 0 then set k4367o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4367 rows=' rows;
else do; set k4367o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND10_PASS=K4367';
else put 'ERROR: ROUND10_FAIL=K4367 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4367:; quit;
