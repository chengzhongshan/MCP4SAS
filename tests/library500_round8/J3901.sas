/* J3901 freq_oneway_chisquare_uniform, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:291 */

data j3901a; do level=1 to 3; count=2; output; end; run;
ods output OneWayChiSq=j3901b;
proc freq data=j3901a; tables level / chisq; weight count; run;
ods output close;
data j3901o; set j3901b; if name1='_PCHI_'; actual=nvalue1; run;

data _null_; if 0 then set j3901o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3901 rows=' rows;
else do; set j3901o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3901';
else put 'ERROR: ROUND8_FAIL=J3901 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3901:; quit;
