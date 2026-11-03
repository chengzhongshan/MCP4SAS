/* M4018 quoted_nrstr_controls; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1419 */
data m4018o; text="%nrstr(%local hidden;)"; actual=index(text,'%local'); run;

data _null_; if 0 then set m4018o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4018 rows=' rows;
else do; set m4018o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND9_PASS=M4018';
else put 'ERROR: ROUND9_FAIL=M4018 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4018:; quit;
