/* G2320 infile_record_length, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

filename rtemp temp;
data _null_; file rtemp; put 'record_11'; run;
data g2320o; infile rtemp length=reclen; input; actual=reclen; run;
filename rtemp clear;

data _null_; if 0 then set g2320o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2320 rows=' rows;
else do; set g2320o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2320';
else put 'ERROR: ROUND5_FAIL=G2320 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2320:; quit;
