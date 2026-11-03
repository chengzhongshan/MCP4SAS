/* G2430 sysmacexist_after_delete, N=11; source: SAS-Useful-Codes/Macros/SuperLearner.sas:978 */

%macro g2430m(); 11 %mend;
%let g2430before=%sysmacexist(g2430m); %sysmacdelete g2430m;
data g2430o; actual=11+&g2430before+%sysmacexist(g2430m); run;
%symdel g2430before;

data _null_; if 0 then set g2430o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2430 rows=' rows;
else do; set g2430o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND5_PASS=G2430';
else put 'ERROR: ROUND5_FAIL=G2430 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2430:; quit;
