/* G2230 implicit_array_do_over, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2230o; x1=11; x2=12; x3=13; array vals x1-x3; do over vals; vals=2*vals; end; actual=sum(of x1-x3); run;

data _null_; if 0 then set g2230o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2230 rows=' rows;
else do; set g2230o; if not missing(actual) and abs(actual-(72))<=1e-9*max(1,abs(72)) then put 'ROUND5_PASS=G2230';
else put 'ERROR: ROUND5_FAIL=G2230 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2230:; quit;
