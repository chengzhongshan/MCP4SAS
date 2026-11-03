/* F1946 array_row_standardization, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data f1946o; array x[3] x1-x3 (7 14 21); center=mean(of x[*]); spread=std(of x[*]); actual=0; do j=1 to dim(x); actual=actual+((x[j]-center)/spread)**2; end; run;

data _null_; if 0 then set f1946o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1946 rows=' rows;
else do; set f1946o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND4_PASS=F1946';
else put 'ERROR: ROUND4_FAIL=F1946 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1946:; quit;
