/* J3905 freq_oneway_chisquare_uniform, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:291 */

data j3905a; do level=1 to 3; count=6; output; end; run;
ods output OneWayChiSq=j3905b;
proc freq data=j3905a; tables level / chisq; weight count; run;
ods output close;
data j3905o; set j3905b; if name1='_PCHI_'; actual=nvalue1; run;

data _null_; if 0 then set j3905o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3905 rows=' rows;
else do; set j3905o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3905';
else put 'ERROR: ROUND8_FAIL=J3905 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3905:; quit;
