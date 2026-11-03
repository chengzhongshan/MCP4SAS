/* M4048 warning_symdel_missing; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:5022 */
%symdel m4048absent;
data m4048o; actual=48; run;

data _null_; if 0 then set m4048o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4048 rows=' rows;
else do; set m4048o; if not missing(actual) and abs(actual-(48))<=1e-9*max(1,abs(48)) then put 'ROUND9_PASS=M4048';
else put 'ERROR: ROUND9_FAIL=M4048 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4048:; quit;
