/* M4050 warning_recursive_parameter_default; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:179 */
%macro m4050m(p=&p); %put NOTE: parameter=&p; %mend; %m4050m; %sysmacdelete m4050m;
data m4050o; actual=50; run;

data _null_; if 0 then set m4050o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4050 rows=' rows;
else do; set m4050o; if not missing(actual) and abs(actual-(50))<=1e-9*max(1,abs(50)) then put 'ROUND9_PASS=M4050';
else put 'ERROR: ROUND9_FAIL=M4050 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4050:; quit;
