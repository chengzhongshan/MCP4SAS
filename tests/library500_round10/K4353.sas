/* K4353 means_minimum_pair_idgroup, N=4; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1996 */

data k4353a; do x=4+2 to 1 by -1; output; end; run;
proc means data=k4353a noprint; var x; output out=k4353b idgroup(min(x) out[2](x)=bottom); run;
data k4353o; set k4353b; actual=bottom_1+bottom_2; run;

data _null_; if 0 then set k4353o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4353 rows=' rows;
else do; set k4353o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND10_PASS=K4353';
else put 'ERROR: ROUND10_FAIL=K4353 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4353:; quit;
