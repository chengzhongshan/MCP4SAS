/* G2282 input_column_pointer, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put 'xx3'; run;
data g2282o; infile rtemp; input @3 actual; run;
filename rtemp clear;

data _null_; if 0 then set g2282o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2282 rows=' rows;
else do; set g2282o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2282';
else put 'ERROR: ROUND5_FAIL=G2282 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2282:; quit;
