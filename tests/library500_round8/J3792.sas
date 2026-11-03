/* J3792 datasets_label_semicolon, N=3; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data j3792a; x=3; run;
proc datasets library=work nolist; modify j3792a(label='phase; two'); quit;
data j3792o; h=open('j3792a','i'); actual=(attrc(h,'LABEL')='phase; two'); rc=close(h); run;

data _null_; if 0 then set j3792o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3792 rows=' rows;
else do; set j3792o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND8_PASS=J3792';
else put 'ERROR: ROUND8_FAIL=J3792 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3792:; quit;
