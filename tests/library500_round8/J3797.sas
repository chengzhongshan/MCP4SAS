/* J3797 datasets_label_semicolon, N=8; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data j3797a; x=8; run;
proc datasets library=work nolist; modify j3797a(label='phase; two'); quit;
data j3797o; h=open('j3797a','i'); actual=(attrc(h,'LABEL')='phase; two'); rc=close(h); run;

data _null_; if 0 then set j3797o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3797 rows=' rows;
else do; set j3797o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND8_PASS=J3797';
else put 'ERROR: ROUND8_FAIL=J3797 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3797:; quit;
