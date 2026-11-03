/* G2319 infile_record_length, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

filename rtemp temp;
data _null_; file rtemp; put 'record_10'; run;
data g2319o; infile rtemp length=reclen; input; actual=reclen; run;
filename rtemp clear;

data _null_; if 0 then set g2319o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2319 rows=' rows;
else do; set g2319o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2319';
else put 'ERROR: ROUND5_FAIL=G2319 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2319:; quit;
