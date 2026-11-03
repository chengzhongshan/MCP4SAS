/* F1947 array_row_standardization, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data f1947o; array x[3] x1-x3 (8 16 24); center=mean(of x[*]); spread=std(of x[*]); actual=0; do j=1 to dim(x); actual=actual+((x[j]-center)/spread)**2; end; run;

data _null_; if 0 then set f1947o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1947 rows=' rows;
else do; set f1947o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND4_PASS=F1947';
else put 'ERROR: ROUND4_FAIL=F1947 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1947:; quit;
