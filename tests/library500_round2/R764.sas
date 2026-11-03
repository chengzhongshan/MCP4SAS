/* R764 array_shift, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data r764o; array v[4] x1-x4 (5 2 3 4); do j=4 to 2 by -1; v[j]=v[j-1]; end; v[1]=0; actual=x1+2*x2+3*x3+4*x4; run;

data _null_; if 0 then set r764o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R764 rows=' rows;
else do; set r764o; if not missing(actual) and abs(actual-(28))<=1e-10*max(1,abs(28)) then put 'ROUND2_PASS=R764';
else put 'ERROR: ROUND2_FAIL=R764 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r764:; quit;
