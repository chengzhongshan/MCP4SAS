/* G2281 input_column_pointer, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put 'xx2'; run;
data g2281o; infile rtemp; input @3 actual; run;
filename rtemp clear;

data _null_; if 0 then set g2281o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2281 rows=' rows;
else do; set g2281o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2281';
else put 'ERROR: ROUND5_FAIL=G2281 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2281:; quit;
