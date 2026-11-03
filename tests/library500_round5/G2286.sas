/* G2286 input_column_pointer, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put 'xx7'; run;
data g2286o; infile rtemp; input @3 actual; run;
filename rtemp clear;

data _null_; if 0 then set g2286o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2286 rows=' rows;
else do; set g2286o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND5_PASS=G2286';
else put 'ERROR: ROUND5_FAIL=G2286 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2286:; quit;
