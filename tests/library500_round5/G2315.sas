/* G2315 infile_record_length, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

filename rtemp temp;
data _null_; file rtemp; put 'record_6'; run;
data g2315o; infile rtemp length=reclen; input; actual=reclen; run;
filename rtemp clear;

data _null_; if 0 then set g2315o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2315 rows=' rows;
else do; set g2315o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2315';
else put 'ERROR: ROUND5_FAIL=G2315 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2315:; quit;
