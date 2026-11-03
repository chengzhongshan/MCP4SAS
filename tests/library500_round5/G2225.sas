/* G2225 implicit_array_do_over, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2225o; x1=6; x2=7; x3=8; array vals x1-x3; do over vals; vals=2*vals; end; actual=sum(of x1-x3); run;

data _null_; if 0 then set g2225o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2225 rows=' rows;
else do; set g2225o; if not missing(actual) and abs(actual-(42))<=1e-9*max(1,abs(42)) then put 'ROUND5_PASS=G2225';
else put 'ERROR: ROUND5_FAIL=G2225 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2225:; quit;
