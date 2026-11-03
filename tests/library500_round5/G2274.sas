/* G2274 input_slash_pointer, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put '5'; put '6'; run;
data g2274o; infile rtemp; input a / b; actual=a+b; run;
filename rtemp clear;

data _null_; if 0 then set g2274o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2274 rows=' rows;
else do; set g2274o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND5_PASS=G2274';
else put 'ERROR: ROUND5_FAIL=G2274 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2274:; quit;
