/* G2210 special_missing_sort_order, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2210a; x=.Z; output; x=.; output; x=._; output; x=.A; output; x=11; output; run;
proc sort data=g2210a out=g2210b; by x; run;
data g2210o; set g2210b; if _n_=1; actual=11+(x=._); run;

data _null_; if 0 then set g2210o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2210 rows=' rows;
else do; set g2210o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND5_PASS=G2210';
else put 'ERROR: ROUND5_FAIL=G2210 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2210:; quit;
