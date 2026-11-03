/* G2220 temporary_array_retention, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2220a; do x=1 to 11; output; end; run;
data g2220o; set g2220a end=last; array sums[2] _temporary_ (0 0); sums[1]+x; sums[2]+x*x; if last; actual=sums[1]+sums[2]; run;

data _null_; if 0 then set g2220o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2220 rows=' rows;
else do; set g2220o; if not missing(actual) and abs(actual-(572))<=1e-9*max(1,abs(572)) then put 'ROUND5_PASS=G2220';
else put 'ERROR: ROUND5_FAIL=G2220 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2220:; quit;
