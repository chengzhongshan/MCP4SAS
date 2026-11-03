/* M4019 macro_option_restoration; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */
%let m4019saved=%sysfunc(getoption(merror,keyword)); options merror;
data m4019o; actual=(getoption('merror')='MERROR'); run; options &m4019saved; %symdel m4019saved;

data _null_; if 0 then set m4019o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4019 rows=' rows;
else do; set m4019o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND9_PASS=M4019';
else put 'ERROR: ROUND9_FAIL=M4019 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4019:; quit;
