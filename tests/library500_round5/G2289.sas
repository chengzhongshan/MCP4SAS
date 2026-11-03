/* G2289 input_column_pointer, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put 'xx10'; run;
data g2289o; infile rtemp; input @3 actual; run;
filename rtemp clear;

data _null_; if 0 then set g2289o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2289 rows=' rows;
else do; set g2289o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND5_PASS=G2289';
else put 'ERROR: ROUND5_FAIL=G2289 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2289:; quit;
