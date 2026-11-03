/* M4003 sequential_open_if_groups; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:400 */
%let m4003v=1; %if 1 %then %do; %let m4003v=2; %end;
%if 1 %then %do; %let m4003v=%eval(&m4003v+3); %end;
data m4003o; actual=&m4003v; run; %symdel m4003v;

data _null_; if 0 then set m4003o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4003 rows=' rows;
else do; set m4003o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND9_PASS=M4003';
else put 'ERROR: ROUND9_FAIL=M4003 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4003:; quit;
