/* M4011 nested_if_inside_macro; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:400 */
%macro m4011m; %if 1 %then %do; %if 2>1 %then %do; data m4011o; actual=21; run; %end; %end; %mend;
%m4011m; %sysmacdelete m4011m;

data _null_; if 0 then set m4011o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4011 rows=' rows;
else do; set m4011o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND9_PASS=M4011';
else put 'ERROR: ROUND9_FAIL=M4011 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4011:; quit;
