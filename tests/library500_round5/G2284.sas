/* G2284 input_column_pointer, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put 'xx5'; run;
data g2284o; infile rtemp; input @3 actual; run;
filename rtemp clear;

data _null_; if 0 then set g2284o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2284 rows=' rows;
else do; set g2284o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2284';
else put 'ERROR: ROUND5_FAIL=G2284 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2284:; quit;
