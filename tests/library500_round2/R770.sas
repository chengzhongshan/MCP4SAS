/* R770 array_shift, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data r770o; array v[4] x1-x4 (11 2 3 4); do j=4 to 2 by -1; v[j]=v[j-1]; end; v[1]=0; actual=x1+2*x2+3*x3+4*x4; run;

data _null_; if 0 then set r770o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R770 rows=' rows;
else do; set r770o; if not missing(actual) and abs(actual-(40))<=1e-10*max(1,abs(40)) then put 'ROUND2_PASS=R770';
else put 'ERROR: ROUND2_FAIL=R770 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r770:; quit;
