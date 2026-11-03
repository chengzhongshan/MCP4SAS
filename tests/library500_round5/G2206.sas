/* G2206 special_missing_sort_order, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2206a; x=.Z; output; x=.; output; x=._; output; x=.A; output; x=7; output; run;
proc sort data=g2206a out=g2206b; by x; run;
data g2206o; set g2206b; if _n_=1; actual=7+(x=._); run;

data _null_; if 0 then set g2206o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2206 rows=' rows;
else do; set g2206o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2206';
else put 'ERROR: ROUND5_FAIL=G2206 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2206:; quit;
