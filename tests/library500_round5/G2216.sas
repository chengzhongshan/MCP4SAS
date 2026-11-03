/* G2216 temporary_array_retention, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2216a; do x=1 to 7; output; end; run;
data g2216o; set g2216a end=last; array sums[2] _temporary_ (0 0); sums[1]+x; sums[2]+x*x; if last; actual=sums[1]+sums[2]; run;

data _null_; if 0 then set g2216o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2216 rows=' rows;
else do; set g2216o; if not missing(actual) and abs(actual-(168))<=1e-9*max(1,abs(168)) then put 'ROUND5_PASS=G2216';
else put 'ERROR: ROUND5_FAIL=G2216 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2216:; quit;
