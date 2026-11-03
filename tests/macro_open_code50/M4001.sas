/* M4001 open_if_then_group; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:400 */
%let m4001v=0; %if 1 %then %do; %let m4001v=11; %end;
data m4001o; actual=&m4001v; run; %symdel m4001v;

data _null_; if 0 then set m4001o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4001 rows=' rows;
else do; set m4001o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND9_PASS=M4001';
else put 'ERROR: ROUND9_FAIL=M4001 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4001:; quit;
