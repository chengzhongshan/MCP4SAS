/* G2190 sort_tagsort, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2190a; do x=11 to 1 by -1; output; end; run;
proc sort data=g2190a out=g2190b tagsort; by x; run;
data g2190o; set g2190b end=last; if last; actual=x; run;

data _null_; if 0 then set g2190o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2190 rows=' rows;
else do; set g2190o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND5_PASS=G2190';
else put 'ERROR: ROUND5_FAIL=G2190 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2190:; quit;
