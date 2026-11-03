/* G2421 sysmacexist_after_delete, N=2; source: SAS-Useful-Codes/Macros/SuperLearner.sas:978 */

%macro g2421m(); 2 %mend;
%let g2421before=%sysmacexist(g2421m); %sysmacdelete g2421m;
data g2421o; actual=2+&g2421before+%sysmacexist(g2421m); run;
%symdel g2421before;

data _null_; if 0 then set g2421o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2421 rows=' rows;
else do; set g2421o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2421';
else put 'ERROR: ROUND5_FAIL=G2421 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2421:; quit;
