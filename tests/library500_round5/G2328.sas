/* G2328 infile_buffer, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'xxxxxxxxx'; run;
data g2328o; infile rtemp; input; actual=countc(_infile_,'x'); run;
filename rtemp clear;

data _null_; if 0 then set g2328o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2328 rows=' rows;
else do; set g2328o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2328';
else put 'ERROR: ROUND5_FAIL=G2328 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2328:; quit;
