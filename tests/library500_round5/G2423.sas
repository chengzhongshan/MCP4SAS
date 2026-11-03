/* G2423 sysmacexist_after_delete, N=4; source: SAS-Useful-Codes/Macros/SuperLearner.sas:978 */

%macro g2423m(); 4 %mend;
%let g2423before=%sysmacexist(g2423m); %sysmacdelete g2423m;
data g2423o; actual=4+&g2423before+%sysmacexist(g2423m); run;
%symdel g2423before;

data _null_; if 0 then set g2423o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2423 rows=' rows;
else do; set g2423o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2423';
else put 'ERROR: ROUND5_FAIL=G2423 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2423:; quit;
