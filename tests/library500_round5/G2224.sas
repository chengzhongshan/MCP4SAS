/* G2224 implicit_array_do_over, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2224o; x1=5; x2=6; x3=7; array vals x1-x3; do over vals; vals=2*vals; end; actual=sum(of x1-x3); run;

data _null_; if 0 then set g2224o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2224 rows=' rows;
else do; set g2224o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND5_PASS=G2224';
else put 'ERROR: ROUND5_FAIL=G2224 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2224:; quit;
