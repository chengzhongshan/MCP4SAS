/* G2280 input_slash_pointer, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put '11'; put '12'; run;
data g2280o; infile rtemp; input a / b; actual=a+b; run;
filename rtemp clear;

data _null_; if 0 then set g2280o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2280 rows=' rows;
else do; set g2280o; if not missing(actual) and abs(actual-(23))<=1e-9*max(1,abs(23)) then put 'ROUND5_PASS=G2280';
else put 'ERROR: ROUND5_FAIL=G2280 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2280:; quit;
