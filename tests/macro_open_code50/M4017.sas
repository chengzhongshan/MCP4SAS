/* M4017 inline_records_are_not_macro_code; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:179 */
data m4017a; input text $char80.; datalines4;
%local hidden; %goto absent; %return;
;;;;
data m4017o; set m4017a; actual=index(text,'%goto'); run;

data _null_; if 0 then set m4017o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4017 rows=' rows;
else do; set m4017o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND9_PASS=M4017';
else put 'ERROR: ROUND9_FAIL=M4017 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4017:; quit;
