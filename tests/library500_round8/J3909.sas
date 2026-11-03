/* J3909 freq_oneway_chisquare_uniform, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:291 */

data j3909a; do level=1 to 3; count=10; output; end; run;
ods output OneWayChiSq=j3909b;
proc freq data=j3909a; tables level / chisq; weight count; run;
ods output close;
data j3909o; set j3909b; if name1='_PCHI_'; actual=nvalue1; run;

data _null_; if 0 then set j3909o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3909 rows=' rows;
else do; set j3909o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3909';
else put 'ERROR: ROUND8_FAIL=J3909 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3909:; quit;
