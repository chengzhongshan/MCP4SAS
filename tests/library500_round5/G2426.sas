/* G2426 sysmacexist_after_delete, N=7; source: SAS-Useful-Codes/Macros/SuperLearner.sas:978 */

%macro g2426m(); 7 %mend;
%let g2426before=%sysmacexist(g2426m); %sysmacdelete g2426m;
data g2426o; actual=7+&g2426before+%sysmacexist(g2426m); run;
%symdel g2426before;

data _null_; if 0 then set g2426o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2426 rows=' rows;
else do; set g2426o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2426';
else put 'ERROR: ROUND5_FAIL=G2426 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2426:; quit;
