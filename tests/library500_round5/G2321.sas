/* G2321 infile_buffer, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'xx'; run;
data g2321o; infile rtemp; input; actual=countc(_infile_,'x'); run;
filename rtemp clear;

data _null_; if 0 then set g2321o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2321 rows=' rows;
else do; set g2321o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2321';
else put 'ERROR: ROUND5_FAIL=G2321 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2321:; quit;
