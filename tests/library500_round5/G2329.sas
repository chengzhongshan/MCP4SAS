/* G2329 infile_buffer, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'xxxxxxxxxx'; run;
data g2329o; infile rtemp; input; actual=countc(_infile_,'x'); run;
filename rtemp clear;

data _null_; if 0 then set g2329o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2329 rows=' rows;
else do; set g2329o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND5_PASS=G2329';
else put 'ERROR: ROUND5_FAIL=G2329 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2329:; quit;
