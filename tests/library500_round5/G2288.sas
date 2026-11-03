/* G2288 input_column_pointer, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put 'xx9'; run;
data g2288o; infile rtemp; input @3 actual; run;
filename rtemp clear;

data _null_; if 0 then set g2288o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2288 rows=' rows;
else do; set g2288o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2288';
else put 'ERROR: ROUND5_FAIL=G2288 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2288:; quit;
