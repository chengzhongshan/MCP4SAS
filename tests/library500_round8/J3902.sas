/* J3902 freq_oneway_chisquare_uniform, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:291 */

data j3902a; do level=1 to 3; count=3; output; end; run;
ods output OneWayChiSq=j3902b;
proc freq data=j3902a; tables level / chisq; weight count; run;
ods output close;
data j3902o; set j3902b; if name1='_PCHI_'; actual=nvalue1; run;

data _null_; if 0 then set j3902o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3902 rows=' rows;
else do; set j3902o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3902';
else put 'ERROR: ROUND8_FAIL=J3902 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3902:; quit;
