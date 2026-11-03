/* G2229 implicit_array_do_over, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2229o; x1=10; x2=11; x3=12; array vals x1-x3; do over vals; vals=2*vals; end; actual=sum(of x1-x3); run;

data _null_; if 0 then set g2229o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2229 rows=' rows;
else do; set g2229o; if not missing(actual) and abs(actual-(66))<=1e-9*max(1,abs(66)) then put 'ROUND5_PASS=G2229';
else put 'ERROR: ROUND5_FAIL=G2229 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2229:; quit;
