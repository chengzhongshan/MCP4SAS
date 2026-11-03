/* R761 array_shift, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data r761o; array v[4] x1-x4 (2 2 3 4); do j=4 to 2 by -1; v[j]=v[j-1]; end; v[1]=0; actual=x1+2*x2+3*x3+4*x4; run;

data _null_; if 0 then set r761o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R761 rows=' rows;
else do; set r761o; if not missing(actual) and abs(actual-(22))<=1e-10*max(1,abs(22)) then put 'ROUND2_PASS=R761';
else put 'ERROR: ROUND2_FAIL=R761 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r761:; quit;
