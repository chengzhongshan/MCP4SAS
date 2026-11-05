/* K4357 means_minimum_pair_idgroup, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1996 */

data k4357a; do x=8+2 to 1 by -1; output; end; run;
proc means data=k4357a noprint; var x; output out=k4357b idgroup(min(x) out[2](x)=bottom); run;
data k4357o; set k4357b; actual=bottom_1+bottom_2; run;

data _null_; if 0 then set k4357o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4357 rows=' rows;
else do; set k4357o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND10_PASS=K4357';
else put 'ERROR: ROUND10_FAIL=K4357 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4357:; quit;
