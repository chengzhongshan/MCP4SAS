/* J3800 datasets_label_semicolon, N=11; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data j3800a; x=11; run;
proc datasets library=work nolist; modify j3800a(label='phase; two'); quit;
data j3800o; h=open('j3800a','i'); actual=(attrc(h,'LABEL')='phase; two'); rc=close(h); run;

data _null_; if 0 then set j3800o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3800 rows=' rows;
else do; set j3800o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND8_PASS=J3800';
else put 'ERROR: ROUND8_FAIL=J3800 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3800:; quit;
