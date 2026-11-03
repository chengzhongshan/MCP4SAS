/* G2208 special_missing_sort_order, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2208a; x=.Z; output; x=.; output; x=._; output; x=.A; output; x=9; output; run;
proc sort data=g2208a out=g2208b; by x; run;
data g2208o; set g2208b; if _n_=1; actual=9+(x=._); run;

data _null_; if 0 then set g2208o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2208 rows=' rows;
else do; set g2208o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND5_PASS=G2208';
else put 'ERROR: ROUND5_FAIL=G2208 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2208:; quit;
