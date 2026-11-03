/* R762 array_shift, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data r762o; array v[4] x1-x4 (3 2 3 4); do j=4 to 2 by -1; v[j]=v[j-1]; end; v[1]=0; actual=x1+2*x2+3*x3+4*x4; run;

data _null_; if 0 then set r762o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R762 rows=' rows;
else do; set r762o; if not missing(actual) and abs(actual-(24))<=1e-10*max(1,abs(24)) then put 'ROUND2_PASS=R762';
else put 'ERROR: ROUND2_FAIL=R762 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r762:; quit;
