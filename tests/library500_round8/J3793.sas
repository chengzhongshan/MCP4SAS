/* J3793 datasets_label_semicolon, N=4; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data j3793a; x=4; run;
proc datasets library=work nolist; modify j3793a(label='phase; two'); quit;
data j3793o; h=open('j3793a','i'); actual=(attrc(h,'LABEL')='phase; two'); rc=close(h); run;

data _null_; if 0 then set j3793o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3793 rows=' rows;
else do; set j3793o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND8_PASS=J3793';
else put 'ERROR: ROUND8_FAIL=J3793 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3793:; quit;
