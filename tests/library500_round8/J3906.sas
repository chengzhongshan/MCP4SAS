/* J3906 freq_oneway_chisquare_uniform, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:291 */

data j3906a; do level=1 to 3; count=7; output; end; run;
ods output OneWayChiSq=j3906b;
proc freq data=j3906a; tables level / chisq; weight count; run;
ods output close;
data j3906o; set j3906b; if name1='_PCHI_'; actual=nvalue1; run;

data _null_; if 0 then set j3906o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3906 rows=' rows;
else do; set j3906o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3906';
else put 'ERROR: ROUND8_FAIL=J3906 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3906:; quit;
