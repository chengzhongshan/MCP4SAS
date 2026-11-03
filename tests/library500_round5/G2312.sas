/* G2312 infile_record_length, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

filename rtemp temp;
data _null_; file rtemp; put 'record_3'; run;
data g2312o; infile rtemp length=reclen; input; actual=reclen; run;
filename rtemp clear;

data _null_; if 0 then set g2312o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2312 rows=' rows;
else do; set g2312o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2312';
else put 'ERROR: ROUND5_FAIL=G2312 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2312:; quit;
