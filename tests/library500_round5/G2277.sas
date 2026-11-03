/* G2277 input_slash_pointer, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put '8'; put '9'; run;
data g2277o; infile rtemp; input a / b; actual=a+b; run;
filename rtemp clear;

data _null_; if 0 then set g2277o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2277 rows=' rows;
else do; set g2277o; if not missing(actual) and abs(actual-(17))<=1e-9*max(1,abs(17)) then put 'ROUND5_PASS=G2277';
else put 'ERROR: ROUND5_FAIL=G2277 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2277:; quit;
