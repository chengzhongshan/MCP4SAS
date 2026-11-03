/* G2228 implicit_array_do_over, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2228o; x1=9; x2=10; x3=11; array vals x1-x3; do over vals; vals=2*vals; end; actual=sum(of x1-x3); run;

data _null_; if 0 then set g2228o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2228 rows=' rows;
else do; set g2228o; if not missing(actual) and abs(actual-(60))<=1e-9*max(1,abs(60)) then put 'ROUND5_PASS=G2228';
else put 'ERROR: ROUND5_FAIL=G2228 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2228:; quit;
