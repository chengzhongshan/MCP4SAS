/* G2185 sort_tagsort, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2185a; do x=6 to 1 by -1; output; end; run;
proc sort data=g2185a out=g2185b tagsort; by x; run;
data g2185o; set g2185b end=last; if last; actual=x; run;

data _null_; if 0 then set g2185o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2185 rows=' rows;
else do; set g2185o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND5_PASS=G2185';
else put 'ERROR: ROUND5_FAIL=G2185 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2185:; quit;
