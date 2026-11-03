/* G2324 infile_buffer, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'xxxxx'; run;
data g2324o; infile rtemp; input; actual=countc(_infile_,'x'); run;
filename rtemp clear;

data _null_; if 0 then set g2324o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2324 rows=' rows;
else do; set g2324o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2324';
else put 'ERROR: ROUND5_FAIL=G2324 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2324:; quit;
