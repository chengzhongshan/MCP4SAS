/* K4365 sort_ascii_case_order, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:79 */

data k4365a; length text $8; text='a'; value=6; output; text='A'; value=2*6; output; run;
proc sort data=k4365a out=k4365b sortseq=ascii; by text; run;
data k4365o; set k4365b(obs=1); actual=value; run;

data _null_; if 0 then set k4365o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4365 rows=' rows;
else do; set k4365o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND10_PASS=K4365';
else put 'ERROR: ROUND10_FAIL=K4365 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4365:; quit;
