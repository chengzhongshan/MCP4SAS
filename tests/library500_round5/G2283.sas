/* G2283 input_column_pointer, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put 'xx4'; run;
data g2283o; infile rtemp; input @3 actual; run;
filename rtemp clear;

data _null_; if 0 then set g2283o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2283 rows=' rows;
else do; set g2283o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND5_PASS=G2283';
else put 'ERROR: ROUND5_FAIL=G2283 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2283:; quit;
