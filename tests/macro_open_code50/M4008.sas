/* M4008 wrapped_return; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:179 */
%macro m4008m; data m4008o; actual=18; run; %return; data m4008o; actual=-1; run; %mend;
%m4008m; %sysmacdelete m4008m;

data _null_; if 0 then set m4008o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4008 rows=' rows;
else do; set m4008o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND9_PASS=M4008';
else put 'ERROR: ROUND9_FAIL=M4008 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4008:; quit;
