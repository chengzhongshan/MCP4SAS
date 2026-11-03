/* G2189 sort_tagsort, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2189a; do x=10 to 1 by -1; output; end; run;
proc sort data=g2189a out=g2189b tagsort; by x; run;
data g2189o; set g2189b end=last; if last; actual=x; run;

data _null_; if 0 then set g2189o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2189 rows=' rows;
else do; set g2189o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND5_PASS=G2189';
else put 'ERROR: ROUND5_FAIL=G2189 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2189:; quit;
