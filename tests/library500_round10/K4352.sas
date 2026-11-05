/* K4352 means_minimum_pair_idgroup, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1996 */

data k4352a; do x=3+2 to 1 by -1; output; end; run;
proc means data=k4352a noprint; var x; output out=k4352b idgroup(min(x) out[2](x)=bottom); run;
data k4352o; set k4352b; actual=bottom_1+bottom_2; run;

data _null_; if 0 then set k4352o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4352 rows=' rows;
else do; set k4352o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND10_PASS=K4352';
else put 'ERROR: ROUND10_FAIL=K4352 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4352:; quit;
