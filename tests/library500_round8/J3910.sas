/* J3910 freq_oneway_chisquare_uniform, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:291 */

data j3910a; do level=1 to 3; count=11; output; end; run;
ods output OneWayChiSq=j3910b;
proc freq data=j3910a; tables level / chisq; weight count; run;
ods output close;
data j3910o; set j3910b; if name1='_PCHI_'; actual=nvalue1; run;

data _null_; if 0 then set j3910o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3910 rows=' rows;
else do; set j3910o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3910';
else put 'ERROR: ROUND8_FAIL=J3910 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3910:; quit;
