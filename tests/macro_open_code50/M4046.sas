/* M4046 warning_unresolved_symbol; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:104 */
options serror; %put NOTE: unresolved=&m4046absent;
data m4046o; actual=46; run;

data _null_; if 0 then set m4046o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4046 rows=' rows;
else do; set m4046o; if not missing(actual) and abs(actual-(46))<=1e-9*max(1,abs(46)) then put 'ROUND9_PASS=M4046';
else put 'ERROR: ROUND9_FAIL=M4046 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4046:; quit;
