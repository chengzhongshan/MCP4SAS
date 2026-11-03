/* G2278 input_slash_pointer, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put '9'; put '10'; run;
data g2278o; infile rtemp; input a / b; actual=a+b; run;
filename rtemp clear;

data _null_; if 0 then set g2278o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2278 rows=' rows;
else do; set g2278o; if not missing(actual) and abs(actual-(19))<=1e-9*max(1,abs(19)) then put 'ROUND5_PASS=G2278';
else put 'ERROR: ROUND5_FAIL=G2278 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2278:; quit;
