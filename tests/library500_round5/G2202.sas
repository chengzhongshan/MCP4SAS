/* G2202 special_missing_sort_order, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2202a; x=.Z; output; x=.; output; x=._; output; x=.A; output; x=3; output; run;
proc sort data=g2202a out=g2202b; by x; run;
data g2202o; set g2202b; if _n_=1; actual=3+(x=._); run;

data _null_; if 0 then set g2202o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2202 rows=' rows;
else do; set g2202o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND5_PASS=G2202';
else put 'ERROR: ROUND5_FAIL=G2202 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2202:; quit;
