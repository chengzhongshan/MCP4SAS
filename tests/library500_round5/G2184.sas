/* G2184 sort_tagsort, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2184a; do x=5 to 1 by -1; output; end; run;
proc sort data=g2184a out=g2184b tagsort; by x; run;
data g2184o; set g2184b end=last; if last; actual=x; run;

data _null_; if 0 then set g2184o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2184 rows=' rows;
else do; set g2184o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2184';
else put 'ERROR: ROUND5_FAIL=G2184 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2184:; quit;
