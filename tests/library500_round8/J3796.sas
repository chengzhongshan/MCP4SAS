/* J3796 datasets_label_semicolon, N=7; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data j3796a; x=7; run;
proc datasets library=work nolist; modify j3796a(label='phase; two'); quit;
data j3796o; h=open('j3796a','i'); actual=(attrc(h,'LABEL')='phase; two'); rc=close(h); run;

data _null_; if 0 then set j3796o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3796 rows=' rows;
else do; set j3796o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND8_PASS=J3796';
else put 'ERROR: ROUND8_FAIL=J3796 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3796:; quit;
