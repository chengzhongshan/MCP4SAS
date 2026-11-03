/* G2276 input_slash_pointer, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put '7'; put '8'; run;
data g2276o; infile rtemp; input a / b; actual=a+b; run;
filename rtemp clear;

data _null_; if 0 then set g2276o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2276 rows=' rows;
else do; set g2276o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND5_PASS=G2276';
else put 'ERROR: ROUND5_FAIL=G2276 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2276:; quit;
