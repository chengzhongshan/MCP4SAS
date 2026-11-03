/* G2207 special_missing_sort_order, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2207a; x=.Z; output; x=.; output; x=._; output; x=.A; output; x=8; output; run;
proc sort data=g2207a out=g2207b; by x; run;
data g2207o; set g2207b; if _n_=1; actual=8+(x=._); run;

data _null_; if 0 then set g2207o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2207 rows=' rows;
else do; set g2207o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2207';
else put 'ERROR: ROUND5_FAIL=G2207 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2207:; quit;
