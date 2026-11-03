/* R871 dsd_quoted_delimiter, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of _str_ and _prxchange_ in transfering space separated input into quoted and comma separated macro variable.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put '"a,b",2'; run;
data r871o; length text $8; infile rtemp dsd dlm=','; input text :$8. n; actual=n+100*(text='a,b'); run;
filename rtemp clear;

data _null_; if 0 then set r871o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R871 rows=' rows;
else do; set r871o; if not missing(actual) and abs(actual-(102))<=1e-10*max(1,abs(102)) then put 'ROUND2_PASS=R871';
else put 'ERROR: ROUND2_FAIL=R871 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r871:; quit;
