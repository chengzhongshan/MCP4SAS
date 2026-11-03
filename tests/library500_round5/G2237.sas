/* G2237 character_array_cmiss, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2237o; array vals[8] $3 c1-c8; do j=1 to 8; if mod(j,2) then vals[j]='x'; end; actual=cmiss(of vals[*]); run;

data _null_; if 0 then set g2237o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2237 rows=' rows;
else do; set g2237o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND5_PASS=G2237';
else put 'ERROR: ROUND5_FAIL=G2237 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2237:; quit;
