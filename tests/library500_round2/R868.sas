/* R868 dsd_empty_fields, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of _str_ and _prxchange_ in transfering space separated input into quoted and comma separated macro variable.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put '9,,3'; run;
data r868o; infile rtemp dsd dlm=','; input a b c; actual=a+c+100*missing(b); run;
filename rtemp clear;

data _null_; if 0 then set r868o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R868 rows=' rows;
else do; set r868o; if not missing(actual) and abs(actual-(112))<=1e-10*max(1,abs(112)) then put 'ROUND2_PASS=R868';
else put 'ERROR: ROUND2_FAIL=R868 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r868:; quit;
