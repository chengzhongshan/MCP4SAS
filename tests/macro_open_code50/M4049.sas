/* M4049 warning_sysmacdelete_missing; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:179 */
%sysmacdelete m4049absent;
data m4049o; actual=49; run;

data _null_; if 0 then set m4049o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4049 rows=' rows;
else do; set m4049o; if not missing(actual) and abs(actual-(49))<=1e-9*max(1,abs(49)) then put 'ROUND9_PASS=M4049';
else put 'ERROR: ROUND9_FAIL=M4049 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4049:; quit;
