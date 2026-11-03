/* J3908 freq_oneway_chisquare_uniform, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:291 */

data j3908a; do level=1 to 3; count=9; output; end; run;
ods output OneWayChiSq=j3908b;
proc freq data=j3908a; tables level / chisq; weight count; run;
ods output close;
data j3908o; set j3908b; if name1='_PCHI_'; actual=nvalue1; run;

data _null_; if 0 then set j3908o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3908 rows=' rows;
else do; set j3908o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3908';
else put 'ERROR: ROUND8_FAIL=J3908 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3908:; quit;
