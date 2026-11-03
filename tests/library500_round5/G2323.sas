/* G2323 infile_buffer, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'xxxx'; run;
data g2323o; infile rtemp; input; actual=countc(_infile_,'x'); run;
filename rtemp clear;

data _null_; if 0 then set g2323o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2323 rows=' rows;
else do; set g2323o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND5_PASS=G2323';
else put 'ERROR: ROUND5_FAIL=G2323 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2323:; quit;
