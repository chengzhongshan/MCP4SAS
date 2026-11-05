/* K4354 means_minimum_pair_idgroup, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1996 */

data k4354a; do x=5+2 to 1 by -1; output; end; run;
proc means data=k4354a noprint; var x; output out=k4354b idgroup(min(x) out[2](x)=bottom); run;
data k4354o; set k4354b; actual=bottom_1+bottom_2; run;

data _null_; if 0 then set k4354o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4354 rows=' rows;
else do; set k4354o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND10_PASS=K4354';
else put 'ERROR: ROUND10_FAIL=K4354 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4354:; quit;
