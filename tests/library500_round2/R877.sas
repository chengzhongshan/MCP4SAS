/* R877 dsd_quoted_delimiter, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of _str_ and _prxchange_ in transfering space separated input into quoted and comma separated macro variable.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put '"a,b",8'; run;
data r877o; length text $8; infile rtemp dsd dlm=','; input text :$8. n; actual=n+100*(text='a,b'); run;
filename rtemp clear;

data _null_; if 0 then set r877o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R877 rows=' rows;
else do; set r877o; if not missing(actual) and abs(actual-(108))<=1e-10*max(1,abs(108)) then put 'ROUND2_PASS=R877';
else put 'ERROR: ROUND2_FAIL=R877 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r877:; quit;
