/* K4355 means_minimum_pair_idgroup, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1996 */

data k4355a; do x=6+2 to 1 by -1; output; end; run;
proc means data=k4355a noprint; var x; output out=k4355b idgroup(min(x) out[2](x)=bottom); run;
data k4355o; set k4355b; actual=bottom_1+bottom_2; run;

data _null_; if 0 then set k4355o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4355 rows=' rows;
else do; set k4355o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND10_PASS=K4355';
else put 'ERROR: ROUND10_FAIL=K4355 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4355:; quit;
