/* J3907 freq_oneway_chisquare_uniform, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:291 */

data j3907a; do level=1 to 3; count=8; output; end; run;
ods output OneWayChiSq=j3907b;
proc freq data=j3907a; tables level / chisq; weight count; run;
ods output close;
data j3907o; set j3907b; if name1='_PCHI_'; actual=nvalue1; run;

data _null_; if 0 then set j3907o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3907 rows=' rows;
else do; set j3907o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3907';
else put 'ERROR: ROUND8_FAIL=J3907 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3907:; quit;
