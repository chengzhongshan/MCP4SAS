/* G2261 pipe_quoted_field, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of _str_ and _prxchange_ in transfering space separated input into quoted and comma separated macro variable.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put '"a|b"|2'; run;
data g2261o; length label $20; infile rtemp dlm='|' dsd; input label :$20. value; actual=value+lengthn(label); run;
filename rtemp clear;

data _null_; if 0 then set g2261o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2261 rows=' rows;
else do; set g2261o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2261';
else put 'ERROR: ROUND5_FAIL=G2261 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2261:; quit;
