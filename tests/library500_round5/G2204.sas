/* G2204 special_missing_sort_order, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2204a; x=.Z; output; x=.; output; x=._; output; x=.A; output; x=5; output; run;
proc sort data=g2204a out=g2204b; by x; run;
data g2204o; set g2204b; if _n_=1; actual=5+(x=._); run;

data _null_; if 0 then set g2204o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2204 rows=' rows;
else do; set g2204o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND5_PASS=G2204';
else put 'ERROR: ROUND5_FAIL=G2204 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2204:; quit;
