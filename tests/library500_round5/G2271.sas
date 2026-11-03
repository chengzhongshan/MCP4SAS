/* G2271 input_slash_pointer, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put '2'; put '3'; run;
data g2271o; infile rtemp; input a / b; actual=a+b; run;
filename rtemp clear;

data _null_; if 0 then set g2271o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2271 rows=' rows;
else do; set g2271o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2271';
else put 'ERROR: ROUND5_FAIL=G2271 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2271:; quit;
