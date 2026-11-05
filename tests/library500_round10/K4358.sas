/* K4358 means_minimum_pair_idgroup, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1996 */

data k4358a; do x=9+2 to 1 by -1; output; end; run;
proc means data=k4358a noprint; var x; output out=k4358b idgroup(min(x) out[2](x)=bottom); run;
data k4358o; set k4358b; actual=bottom_1+bottom_2; run;

data _null_; if 0 then set k4358o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4358 rows=' rows;
else do; set k4358o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND10_PASS=K4358';
else put 'ERROR: ROUND10_FAIL=K4358 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4358:; quit;
