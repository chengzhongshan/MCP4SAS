/* G2273 input_slash_pointer, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put '4'; put '5'; run;
data g2273o; infile rtemp; input a / b; actual=a+b; run;
filename rtemp clear;

data _null_; if 0 then set g2273o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2273 rows=' rows;
else do; set g2273o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2273';
else put 'ERROR: ROUND5_FAIL=G2273 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2273:; quit;
