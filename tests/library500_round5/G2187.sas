/* G2187 sort_tagsort, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2187a; do x=8 to 1 by -1; output; end; run;
proc sort data=g2187a out=g2187b tagsort; by x; run;
data g2187o; set g2187b end=last; if last; actual=x; run;

data _null_; if 0 then set g2187o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2187 rows=' rows;
else do; set g2187o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2187';
else put 'ERROR: ROUND5_FAIL=G2187 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2187:; quit;
