/* G2183 sort_tagsort, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2183a; do x=4 to 1 by -1; output; end; run;
proc sort data=g2183a out=g2183b tagsort; by x; run;
data g2183o; set g2183b end=last; if last; actual=x; run;

data _null_; if 0 then set g2183o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2183 rows=' rows;
else do; set g2183o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND5_PASS=G2183';
else put 'ERROR: ROUND5_FAIL=G2183 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2183:; quit;
