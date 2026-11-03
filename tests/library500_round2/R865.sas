/* R865 dsd_empty_fields, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of _str_ and _prxchange_ in transfering space separated input into quoted and comma separated macro variable.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put '6,,3'; run;
data r865o; infile rtemp dsd dlm=','; input a b c; actual=a+c+100*missing(b); run;
filename rtemp clear;

data _null_; if 0 then set r865o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R865 rows=' rows;
else do; set r865o; if not missing(actual) and abs(actual-(109))<=1e-10*max(1,abs(109)) then put 'ROUND2_PASS=R865';
else put 'ERROR: ROUND2_FAIL=R865 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r865:; quit;
