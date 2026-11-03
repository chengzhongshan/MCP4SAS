/* M4010 uninvoked_macro_local_is_inert; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:179 */
%macro m4010m; %local m4010hidden; %let m4010hidden=1; %mend;
data m4010o; actual=%symexist(m4010hidden); run; %sysmacdelete m4010m;

data _null_; if 0 then set m4010o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4010 rows=' rows;
else do; set m4010o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND9_PASS=M4010';
else put 'ERROR: ROUND9_FAIL=M4010 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4010:; quit;
