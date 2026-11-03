/* M4009 wrapped_goto; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:3038 */
%macro m4009m; %goto done; data m4009o; actual=-1; run; %done: data m4009o; actual=19; run; %mend;
%m4009m; %sysmacdelete m4009m;

data _null_; if 0 then set m4009o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4009 rows=' rows;
else do; set m4009o; if not missing(actual) and abs(actual-(19))<=1e-9*max(1,abs(19)) then put 'ROUND9_PASS=M4009';
else put 'ERROR: ROUND9_FAIL=M4009 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4009:; quit;
