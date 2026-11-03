/* G2201 special_missing_sort_order, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2201a; x=.Z; output; x=.; output; x=._; output; x=.A; output; x=2; output; run;
proc sort data=g2201a out=g2201b; by x; run;
data g2201o; set g2201b; if _n_=1; actual=2+(x=._); run;

data _null_; if 0 then set g2201o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2201 rows=' rows;
else do; set g2201o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2201';
else put 'ERROR: ROUND5_FAIL=G2201 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2201:; quit;
