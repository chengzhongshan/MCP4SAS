/* M4005 wrapped_while_loop; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:503 */
%macro m4005m; %local i; %let i=1; %do %while(&i<5); %let i=%eval(&i+1); %end;
data m4005o; actual=&i; run; %mend; %m4005m; %sysmacdelete m4005m;

data _null_; if 0 then set m4005o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4005 rows=' rows;
else do; set m4005o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND9_PASS=M4005';
else put 'ERROR: ROUND9_FAIL=M4005 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4005:; quit;
