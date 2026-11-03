/* G2186 sort_tagsort, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2186a; do x=7 to 1 by -1; output; end; run;
proc sort data=g2186a out=g2186b tagsort; by x; run;
data g2186o; set g2186b end=last; if last; actual=x; run;

data _null_; if 0 then set g2186o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2186 rows=' rows;
else do; set g2186o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND5_PASS=G2186';
else put 'ERROR: ROUND5_FAIL=G2186 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2186:; quit;
