/* J3794 datasets_label_semicolon, N=5; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data j3794a; x=5; run;
proc datasets library=work nolist; modify j3794a(label='phase; two'); quit;
data j3794o; h=open('j3794a','i'); actual=(attrc(h,'LABEL')='phase; two'); rc=close(h); run;

data _null_; if 0 then set j3794o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3794 rows=' rows;
else do; set j3794o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND8_PASS=J3794';
else put 'ERROR: ROUND8_FAIL=J3794 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3794:; quit;
