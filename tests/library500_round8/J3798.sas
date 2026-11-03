/* J3798 datasets_label_semicolon, N=9; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data j3798a; x=9; run;
proc datasets library=work nolist; modify j3798a(label='phase; two'); quit;
data j3798o; h=open('j3798a','i'); actual=(attrc(h,'LABEL')='phase; two'); rc=close(h); run;

data _null_; if 0 then set j3798o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3798 rows=' rows;
else do; set j3798o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND8_PASS=J3798';
else put 'ERROR: ROUND8_FAIL=J3798 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3798:; quit;
