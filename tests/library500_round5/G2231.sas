/* G2231 character_array_cmiss, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:81 */

data g2231o; array vals[2] $3 c1-c2; do j=1 to 2; if mod(j,2) then vals[j]='x'; end; actual=cmiss(of vals[*]); run;

data _null_; if 0 then set g2231o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2231 rows=' rows;
else do; set g2231o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2231';
else put 'ERROR: ROUND5_FAIL=G2231 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2231:; quit;
