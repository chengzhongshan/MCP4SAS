/* M4007 local_shadows_global; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:584 */
%let m4007v=17; %macro m4007m; %local m4007v; %let m4007v=99; %mend; %m4007m;
data m4007o; actual=&m4007v; run; %symdel m4007v; %sysmacdelete m4007m;

data _null_; if 0 then set m4007o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4007 rows=' rows;
else do; set m4007o; if not missing(actual) and abs(actual-(17))<=1e-9*max(1,abs(17)) then put 'ROUND9_PASS=M4007';
else put 'ERROR: ROUND9_FAIL=M4007 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4007:; quit;
