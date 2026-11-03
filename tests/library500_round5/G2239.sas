/* G2239 character_array_cmiss, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2239o; array vals[10] $3 c1-c10; do j=1 to 10; if mod(j,2) then vals[j]='x'; end; actual=cmiss(of vals[*]); run;

data _null_; if 0 then set g2239o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2239 rows=' rows;
else do; set g2239o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2239';
else put 'ERROR: ROUND5_FAIL=G2239 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2239:; quit;
