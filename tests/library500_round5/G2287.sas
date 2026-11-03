/* G2287 input_column_pointer, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put 'xx8'; run;
data g2287o; infile rtemp; input @3 actual; run;
filename rtemp clear;

data _null_; if 0 then set g2287o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2287 rows=' rows;
else do; set g2287o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2287';
else put 'ERROR: ROUND5_FAIL=G2287 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2287:; quit;
