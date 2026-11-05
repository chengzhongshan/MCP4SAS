/* K4356 means_minimum_pair_idgroup, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1996 */

data k4356a; do x=7+2 to 1 by -1; output; end; run;
proc means data=k4356a noprint; var x; output out=k4356b idgroup(min(x) out[2](x)=bottom); run;
data k4356o; set k4356b; actual=bottom_1+bottom_2; run;

data _null_; if 0 then set k4356o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4356 rows=' rows;
else do; set k4356o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND10_PASS=K4356';
else put 'ERROR: ROUND10_FAIL=K4356 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4356:; quit;
