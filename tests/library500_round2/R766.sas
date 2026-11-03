/* R766 array_shift, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data r766o; array v[4] x1-x4 (7 2 3 4); do j=4 to 2 by -1; v[j]=v[j-1]; end; v[1]=0; actual=x1+2*x2+3*x3+4*x4; run;

data _null_; if 0 then set r766o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R766 rows=' rows;
else do; set r766o; if not missing(actual) and abs(actual-(32))<=1e-10*max(1,abs(32)) then put 'ROUND2_PASS=R766';
else put 'ERROR: ROUND2_FAIL=R766 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r766:; quit;
