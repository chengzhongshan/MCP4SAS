/* M4006 wrapped_until_loop; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:480 */
%macro m4006m; %local i; %let i=0; %do %until(&i=3); %let i=%eval(&i+1); %end;
data m4006o; actual=&i; run; %mend; %m4006m; %sysmacdelete m4006m;

data _null_; if 0 then set m4006o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4006 rows=' rows;
else do; set m4006o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND9_PASS=M4006';
else put 'ERROR: ROUND9_FAIL=M4006 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4006:; quit;
