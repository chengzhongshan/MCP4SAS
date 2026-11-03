/* M4012 str_protects_semicolon; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1357 */
%let m4012v=%str(alpha;beta);
data m4012o; actual=index(symget('m4012v'),';'); run; %symdel m4012v;

data _null_; if 0 then set m4012o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4012 rows=' rows;
else do; set m4012o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND9_PASS=M4012';
else put 'ERROR: ROUND9_FAIL=M4012 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4012:; quit;
