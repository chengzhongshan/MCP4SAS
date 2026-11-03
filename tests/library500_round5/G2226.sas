/* G2226 implicit_array_do_over, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2226o; x1=7; x2=8; x3=9; array vals x1-x3; do over vals; vals=2*vals; end; actual=sum(of x1-x3); run;

data _null_; if 0 then set g2226o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2226 rows=' rows;
else do; set g2226o; if not missing(actual) and abs(actual-(48))<=1e-9*max(1,abs(48)) then put 'ROUND5_PASS=G2226';
else put 'ERROR: ROUND5_FAIL=G2226 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2226:; quit;
