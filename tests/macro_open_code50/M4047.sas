/* M4047 warning_unresolved_invocation_in_put; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:179 */
options merror; %put NOTE: unresolved=%m4047absent();
data m4047o; actual=47; run;

data _null_; if 0 then set m4047o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4047 rows=' rows;
else do; set m4047o; if not missing(actual) and abs(actual-(47))<=1e-9*max(1,abs(47)) then put 'ROUND9_PASS=M4047';
else put 'ERROR: ROUND9_FAIL=M4047 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4047:; quit;
