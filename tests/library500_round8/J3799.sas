/* J3799 datasets_label_semicolon, N=10; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data j3799a; x=10; run;
proc datasets library=work nolist; modify j3799a(label='phase; two'); quit;
data j3799o; h=open('j3799a','i'); actual=(attrc(h,'LABEL')='phase; two'); rc=close(h); run;

data _null_; if 0 then set j3799o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3799 rows=' rows;
else do; set j3799o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND8_PASS=J3799';
else put 'ERROR: ROUND8_FAIL=J3799 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3799:; quit;
