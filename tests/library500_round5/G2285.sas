/* G2285 input_column_pointer, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put 'xx6'; run;
data g2285o; infile rtemp; input @3 actual; run;
filename rtemp clear;

data _null_; if 0 then set g2285o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2285 rows=' rows;
else do; set g2285o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND5_PASS=G2285';
else put 'ERROR: ROUND5_FAIL=G2285 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2285:; quit;
