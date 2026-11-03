/* R878 dsd_quoted_delimiter, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of _str_ and _prxchange_ in transfering space separated input into quoted and comma separated macro variable.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put '"a,b",9'; run;
data r878o; length text $8; infile rtemp dsd dlm=','; input text :$8. n; actual=n+100*(text='a,b'); run;
filename rtemp clear;

data _null_; if 0 then set r878o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R878 rows=' rows;
else do; set r878o; if not missing(actual) and abs(actual-(109))<=1e-10*max(1,abs(109)) then put 'ROUND2_PASS=R878';
else put 'ERROR: ROUND2_FAIL=R878 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r878:; quit;
