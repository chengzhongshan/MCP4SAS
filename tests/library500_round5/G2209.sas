/* G2209 special_missing_sort_order, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2209a; x=.Z; output; x=.; output; x=._; output; x=.A; output; x=10; output; run;
proc sort data=g2209a out=g2209b; by x; run;
data g2209o; set g2209b; if _n_=1; actual=10+(x=._); run;

data _null_; if 0 then set g2209o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2209 rows=' rows;
else do; set g2209o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND5_PASS=G2209';
else put 'ERROR: ROUND5_FAIL=G2209 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2209:; quit;
