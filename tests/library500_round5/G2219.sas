/* G2219 temporary_array_retention, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2219a; do x=1 to 10; output; end; run;
data g2219o; set g2219a end=last; array sums[2] _temporary_ (0 0); sums[1]+x; sums[2]+x*x; if last; actual=sums[1]+sums[2]; run;

data _null_; if 0 then set g2219o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2219 rows=' rows;
else do; set g2219o; if not missing(actual) and abs(actual-(440))<=1e-9*max(1,abs(440)) then put 'ROUND5_PASS=G2219';
else put 'ERROR: ROUND5_FAIL=G2219 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2219:; quit;
