/* G2182 sort_tagsort, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2182a; do x=3 to 1 by -1; output; end; run;
proc sort data=g2182a out=g2182b tagsort; by x; run;
data g2182o; set g2182b end=last; if last; actual=x; run;

data _null_; if 0 then set g2182o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2182 rows=' rows;
else do; set g2182o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2182';
else put 'ERROR: ROUND5_FAIL=G2182 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2182:; quit;
