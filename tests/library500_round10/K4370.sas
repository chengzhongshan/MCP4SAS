/* K4370 sort_ascii_case_order, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:79 */

data k4370a; length text $8; text='a'; value=11; output; text='A'; value=2*11; output; run;
proc sort data=k4370a out=k4370b sortseq=ascii; by text; run;
data k4370o; set k4370b(obs=1); actual=value; run;

data _null_; if 0 then set k4370o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4370 rows=' rows;
else do; set k4370o; if not missing(actual) and abs(actual-(22))<=1e-9*max(1,abs(22)) then put 'ROUND10_PASS=K4370';
else put 'ERROR: ROUND10_FAIL=K4370 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4370:; quit;
