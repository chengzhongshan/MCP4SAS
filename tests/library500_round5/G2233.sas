/* G2233 character_array_cmiss, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2233o; array vals[4] $3 c1-c4; do j=1 to 4; if mod(j,2) then vals[j]='x'; end; actual=cmiss(of vals[*]); run;

data _null_; if 0 then set g2233o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2233 rows=' rows;
else do; set g2233o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2233';
else put 'ERROR: ROUND5_FAIL=G2233 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2233:; quit;
