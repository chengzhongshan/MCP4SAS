/* G2203 special_missing_sort_order, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2203a; x=.Z; output; x=.; output; x=._; output; x=.A; output; x=4; output; run;
proc sort data=g2203a out=g2203b; by x; run;
data g2203o; set g2203b; if _n_=1; actual=4+(x=._); run;

data _null_; if 0 then set g2203o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2203 rows=' rows;
else do; set g2203o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2203';
else put 'ERROR: ROUND5_FAIL=G2203 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2203:; quit;
