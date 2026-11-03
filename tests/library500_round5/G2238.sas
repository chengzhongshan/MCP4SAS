/* G2238 character_array_cmiss, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2238o; array vals[9] $3 c1-c9; do j=1 to 9; if mod(j,2) then vals[j]='x'; end; actual=cmiss(of vals[*]); run;

data _null_; if 0 then set g2238o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2238 rows=' rows;
else do; set g2238o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND5_PASS=G2238';
else put 'ERROR: ROUND5_FAIL=G2238 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2238:; quit;
