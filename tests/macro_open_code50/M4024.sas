/* M4024 indirect_macro_variable; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:104 */
%let m4024ptr=m4024value; %let m4024value=34;
data m4024o; actual=&&&m4024ptr; run; %symdel m4024ptr m4024value;

data _null_; if 0 then set m4024o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4024 rows=' rows;
else do; set m4024o; if not missing(actual) and abs(actual-(34))<=1e-9*max(1,abs(34)) then put 'ROUND9_PASS=M4024';
else put 'ERROR: ROUND9_FAIL=M4024 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4024:; quit;
