/* G2205 special_missing_sort_order, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2205a; x=.Z; output; x=.; output; x=._; output; x=.A; output; x=6; output; run;
proc sort data=g2205a out=g2205b; by x; run;
data g2205o; set g2205b; if _n_=1; actual=6+(x=._); run;

data _null_; if 0 then set g2205o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2205 rows=' rows;
else do; set g2205o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND5_PASS=G2205';
else put 'ERROR: ROUND5_FAIL=G2205 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2205:; quit;
