/* G2227 implicit_array_do_over, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2227o; x1=8; x2=9; x3=10; array vals x1-x3; do over vals; vals=2*vals; end; actual=sum(of x1-x3); run;

data _null_; if 0 then set g2227o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2227 rows=' rows;
else do; set g2227o; if not missing(actual) and abs(actual-(54))<=1e-9*max(1,abs(54)) then put 'ROUND5_PASS=G2227';
else put 'ERROR: ROUND5_FAIL=G2227 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2227:; quit;
