/* G2422 sysmacexist_after_delete, N=3; source: SAS-Useful-Codes/Macros/SuperLearner.sas:978 */

%macro g2422m(); 3 %mend;
%let g2422before=%sysmacexist(g2422m); %sysmacdelete g2422m;
data g2422o; actual=3+&g2422before+%sysmacexist(g2422m); run;
%symdel g2422before;

data _null_; if 0 then set g2422o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2422 rows=' rows;
else do; set g2422o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND5_PASS=G2422';
else put 'ERROR: ROUND5_FAIL=G2422 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2422:; quit;
