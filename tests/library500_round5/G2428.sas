/* G2428 sysmacexist_after_delete, N=9; source: SAS-Useful-Codes/Macros/SuperLearner.sas:978 */

%macro g2428m(); 9 %mend;
%let g2428before=%sysmacexist(g2428m); %sysmacdelete g2428m;
data g2428o; actual=9+&g2428before+%sysmacexist(g2428m); run;
%symdel g2428before;

data _null_; if 0 then set g2428o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2428 rows=' rows;
else do; set g2428o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND5_PASS=G2428';
else put 'ERROR: ROUND5_FAIL=G2428 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2428:; quit;
