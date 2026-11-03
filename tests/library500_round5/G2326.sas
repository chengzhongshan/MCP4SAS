/* G2326 infile_buffer, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'xxxxxxx'; run;
data g2326o; infile rtemp; input; actual=countc(_infile_,'x'); run;
filename rtemp clear;

data _null_; if 0 then set g2326o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2326 rows=' rows;
else do; set g2326o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND5_PASS=G2326';
else put 'ERROR: ROUND5_FAIL=G2326 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2326:; quit;
