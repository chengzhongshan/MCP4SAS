/* G2325 infile_buffer, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'xxxxxx'; run;
data g2325o; infile rtemp; input; actual=countc(_infile_,'x'); run;
filename rtemp clear;

data _null_; if 0 then set g2325o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2325 rows=' rows;
else do; set g2325o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND5_PASS=G2325';
else put 'ERROR: ROUND5_FAIL=G2325 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2325:; quit;
