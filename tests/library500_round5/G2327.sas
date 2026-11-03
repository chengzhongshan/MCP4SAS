/* G2327 infile_buffer, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'xxxxxxxx'; run;
data g2327o; infile rtemp; input; actual=countc(_infile_,'x'); run;
filename rtemp clear;

data _null_; if 0 then set g2327o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2327 rows=' rows;
else do; set g2327o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2327';
else put 'ERROR: ROUND5_FAIL=G2327 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2327:; quit;
