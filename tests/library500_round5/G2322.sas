/* G2322 infile_buffer, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'xxx'; run;
data g2322o; infile rtemp; input; actual=countc(_infile_,'x'); run;
filename rtemp clear;

data _null_; if 0 then set g2322o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2322 rows=' rows;
else do; set g2322o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2322';
else put 'ERROR: ROUND5_FAIL=G2322 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2322:; quit;
