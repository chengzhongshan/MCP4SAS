/* J3618 reg_noint_slope, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3618a; do x=1 to 9; y=3*x; output; end; run;
proc reg data=j3618a outest=j3618b noprint; model y=x / noint; run; quit;
data j3618o; set j3618b; actual=x; run;

data _null_; if 0 then set j3618o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3618 rows=' rows;
else do; set j3618o; if not missing(actual) and abs(actual-(3))<=1e-6*max(1,abs(3)) then put 'ROUND8_PASS=J3618';
else put 'ERROR: ROUND8_FAIL=J3618 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3618:; quit;
