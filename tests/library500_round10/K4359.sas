/* K4359 means_minimum_pair_idgroup, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1996 */

data k4359a; do x=10+2 to 1 by -1; output; end; run;
proc means data=k4359a noprint; var x; output out=k4359b idgroup(min(x) out[2](x)=bottom); run;
data k4359o; set k4359b; actual=bottom_1+bottom_2; run;

data _null_; if 0 then set k4359o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4359 rows=' rows;
else do; set k4359o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND10_PASS=K4359';
else put 'ERROR: ROUND10_FAIL=K4359 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4359:; quit;
