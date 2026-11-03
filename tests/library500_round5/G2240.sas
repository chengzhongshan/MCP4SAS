/* G2240 character_array_cmiss, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2240o; array vals[11] $3 c1-c11; do j=1 to 11; if mod(j,2) then vals[j]='x'; end; actual=cmiss(of vals[*]); run;

data _null_; if 0 then set g2240o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2240 rows=' rows;
else do; set g2240o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2240';
else put 'ERROR: ROUND5_FAIL=G2240 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2240:; quit;
