/* G2236 character_array_cmiss, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2236o; array vals[7] $3 c1-c7; do j=1 to 7; if mod(j,2) then vals[j]='x'; end; actual=cmiss(of vals[*]); run;

data _null_; if 0 then set g2236o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2236 rows=' rows;
else do; set g2236o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2236';
else put 'ERROR: ROUND5_FAIL=G2236 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2236:; quit;
