/* G2222 implicit_array_do_over, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2222o; x1=3; x2=4; x3=5; array vals x1-x3; do over vals; vals=2*vals; end; actual=sum(of x1-x3); run;

data _null_; if 0 then set g2222o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2222 rows=' rows;
else do; set g2222o; if not missing(actual) and abs(actual-(24))<=1e-9*max(1,abs(24)) then put 'ROUND5_PASS=G2222';
else put 'ERROR: ROUND5_FAIL=G2222 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2222:; quit;
