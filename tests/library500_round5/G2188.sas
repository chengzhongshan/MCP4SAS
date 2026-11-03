/* G2188 sort_tagsort, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2188a; do x=9 to 1 by -1; output; end; run;
proc sort data=g2188a out=g2188b tagsort; by x; run;
data g2188o; set g2188b end=last; if last; actual=x; run;

data _null_; if 0 then set g2188o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2188 rows=' rows;
else do; set g2188o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2188';
else put 'ERROR: ROUND5_FAIL=G2188 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2188:; quit;
