/* G2218 temporary_array_retention, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2218a; do x=1 to 9; output; end; run;
data g2218o; set g2218a end=last; array sums[2] _temporary_ (0 0); sums[1]+x; sums[2]+x*x; if last; actual=sums[1]+sums[2]; run;

data _null_; if 0 then set g2218o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2218 rows=' rows;
else do; set g2218o; if not missing(actual) and abs(actual-(330))<=1e-9*max(1,abs(330)) then put 'ROUND5_PASS=G2218';
else put 'ERROR: ROUND5_FAIL=G2218 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2218:; quit;
