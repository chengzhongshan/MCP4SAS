/* G2223 implicit_array_do_over, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2223o; x1=4; x2=5; x3=6; array vals x1-x3; do over vals; vals=2*vals; end; actual=sum(of x1-x3); run;

data _null_; if 0 then set g2223o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2223 rows=' rows;
else do; set g2223o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND5_PASS=G2223';
else put 'ERROR: ROUND5_FAIL=G2223 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2223:; quit;
