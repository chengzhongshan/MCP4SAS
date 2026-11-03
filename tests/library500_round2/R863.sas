/* R863 dsd_empty_fields, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of _str_ and _prxchange_ in transfering space separated input into quoted and comma separated macro variable.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put '4,,3'; run;
data r863o; infile rtemp dsd dlm=','; input a b c; actual=a+c+100*missing(b); run;
filename rtemp clear;

data _null_; if 0 then set r863o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R863 rows=' rows;
else do; set r863o; if not missing(actual) and abs(actual-(107))<=1e-10*max(1,abs(107)) then put 'ROUND2_PASS=R863';
else put 'ERROR: ROUND2_FAIL=R863 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r863:; quit;
