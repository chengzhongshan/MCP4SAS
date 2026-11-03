/* R875 dsd_quoted_delimiter, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of _str_ and _prxchange_ in transfering space separated input into quoted and comma separated macro variable.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put '"a,b",6'; run;
data r875o; length text $8; infile rtemp dsd dlm=','; input text :$8. n; actual=n+100*(text='a,b'); run;
filename rtemp clear;

data _null_; if 0 then set r875o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R875 rows=' rows;
else do; set r875o; if not missing(actual) and abs(actual-(106))<=1e-10*max(1,abs(106)) then put 'ROUND2_PASS=R875';
else put 'ERROR: ROUND2_FAIL=R875 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r875:; quit;
