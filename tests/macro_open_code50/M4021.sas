/* M4021 decimal_sysevalf_open_code; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1495 */
%let m4021v=%sysevalf(1.5+2.25);
data m4021o; actual=&m4021v; run; %symdel m4021v;

data _null_; if 0 then set m4021o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4021 rows=' rows;
else do; set m4021o; if not missing(actual) and abs(actual-(3.75))<=1e-9*max(1,abs(3.75)) then put 'ROUND9_PASS=M4021';
else put 'ERROR: ROUND9_FAIL=M4021 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4021:; quit;
