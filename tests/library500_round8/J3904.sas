/* J3904 freq_oneway_chisquare_uniform, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:291 */

data j3904a; do level=1 to 3; count=5; output; end; run;
ods output OneWayChiSq=j3904b;
proc freq data=j3904a; tables level / chisq; weight count; run;
ods output close;
data j3904o; set j3904b; if name1='_PCHI_'; actual=nvalue1; run;

data _null_; if 0 then set j3904o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3904 rows=' rows;
else do; set j3904o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3904';
else put 'ERROR: ROUND8_FAIL=J3904 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3904:; quit;
