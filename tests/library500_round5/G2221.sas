/* G2221 implicit_array_do_over, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2221o; x1=2; x2=3; x3=4; array vals x1-x3; do over vals; vals=2*vals; end; actual=sum(of x1-x3); run;

data _null_; if 0 then set g2221o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2221 rows=' rows;
else do; set g2221o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND5_PASS=G2221';
else put 'ERROR: ROUND5_FAIL=G2221 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2221:; quit;
