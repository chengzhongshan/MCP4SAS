/* J3791 datasets_label_semicolon, N=2; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data j3791a; x=2; run;
proc datasets library=work nolist; modify j3791a(label='phase; two'); quit;
data j3791o; h=open('j3791a','i'); actual=(attrc(h,'LABEL')='phase; two'); rc=close(h); run;

data _null_; if 0 then set j3791o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3791 rows=' rows;
else do; set j3791o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND8_PASS=J3791';
else put 'ERROR: ROUND8_FAIL=J3791 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3791:; quit;
