/* J3795 datasets_label_semicolon, N=6; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data j3795a; x=6; run;
proc datasets library=work nolist; modify j3795a(label='phase; two'); quit;
data j3795o; h=open('j3795a','i'); actual=(attrc(h,'LABEL')='phase; two'); rc=close(h); run;

data _null_; if 0 then set j3795o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3795 rows=' rows;
else do; set j3795o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND8_PASS=J3795';
else put 'ERROR: ROUND8_FAIL=J3795 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3795:; quit;
