/* G2275 input_slash_pointer, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put '6'; put '7'; run;
data g2275o; infile rtemp; input a / b; actual=a+b; run;
filename rtemp clear;

data _null_; if 0 then set g2275o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2275 rows=' rows;
else do; set g2275o; if not missing(actual) and abs(actual-(13))<=1e-9*max(1,abs(13)) then put 'ROUND5_PASS=G2275';
else put 'ERROR: ROUND5_FAIL=G2275 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2275:; quit;
