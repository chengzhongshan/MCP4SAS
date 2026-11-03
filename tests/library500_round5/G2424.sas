/* G2424 sysmacexist_after_delete, N=5; source: SAS-Useful-Codes/Macros/SuperLearner.sas:978 */

%macro g2424m(); 5 %mend;
%let g2424before=%sysmacexist(g2424m); %sysmacdelete g2424m;
data g2424o; actual=5+&g2424before+%sysmacexist(g2424m); run;
%symdel g2424before;

data _null_; if 0 then set g2424o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2424 rows=' rows;
else do; set g2424o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND5_PASS=G2424';
else put 'ERROR: ROUND5_FAIL=G2424 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2424:; quit;
