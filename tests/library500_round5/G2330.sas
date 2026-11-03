/* G2330 infile_buffer, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'xxxxxxxxxxx'; run;
data g2330o; infile rtemp; input; actual=countc(_infile_,'x'); run;
filename rtemp clear;

data _null_; if 0 then set g2330o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2330 rows=' rows;
else do; set g2330o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND5_PASS=G2330';
else put 'ERROR: ROUND5_FAIL=G2330 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2330:; quit;
