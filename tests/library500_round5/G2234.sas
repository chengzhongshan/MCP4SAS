/* G2234 character_array_cmiss, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2234o; array vals[5] $3 c1-c5; do j=1 to 5; if mod(j,2) then vals[j]='x'; end; actual=cmiss(of vals[*]); run;

data _null_; if 0 then set g2234o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2234 rows=' rows;
else do; set g2234o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2234';
else put 'ERROR: ROUND5_FAIL=G2234 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2234:; quit;
