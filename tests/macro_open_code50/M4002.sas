/* M4002 open_if_false_else_group; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:400 */
%let m4002v=0; %if 0 %then %do; %let m4002v=-1; %end; %else %do; %let m4002v=12; %end;
data m4002o; actual=&m4002v; run; %symdel m4002v;

data _null_; if 0 then set m4002o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4002 rows=' rows;
else do; set m4002o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND9_PASS=M4002';
else put 'ERROR: ROUND9_FAIL=M4002 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4002:; quit;
