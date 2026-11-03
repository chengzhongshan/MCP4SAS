/* G2279 input_slash_pointer, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put '10'; put '11'; run;
data g2279o; infile rtemp; input a / b; actual=a+b; run;
filename rtemp clear;

data _null_; if 0 then set g2279o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2279 rows=' rows;
else do; set g2279o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND5_PASS=G2279';
else put 'ERROR: ROUND5_FAIL=G2279 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2279:; quit;
