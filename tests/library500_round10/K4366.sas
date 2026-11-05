/* K4366 sort_ascii_case_order, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:79 */

data k4366a; length text $8; text='a'; value=7; output; text='A'; value=2*7; output; run;
proc sort data=k4366a out=k4366b sortseq=ascii; by text; run;
data k4366o; set k4366b(obs=1); actual=value; run;

data _null_; if 0 then set k4366o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4366 rows=' rows;
else do; set k4366o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND10_PASS=K4366';
else put 'ERROR: ROUND10_FAIL=K4366 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4366:; quit;
