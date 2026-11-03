/* G2181 sort_tagsort, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2181a; do x=2 to 1 by -1; output; end; run;
proc sort data=g2181a out=g2181b tagsort; by x; run;
data g2181o; set g2181b end=last; if last; actual=x; run;

data _null_; if 0 then set g2181o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2181 rows=' rows;
else do; set g2181o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2181';
else put 'ERROR: ROUND5_FAIL=G2181 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2181:; quit;
