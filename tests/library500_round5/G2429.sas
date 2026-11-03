/* G2429 sysmacexist_after_delete, N=10; source: SAS-Useful-Codes/Macros/SuperLearner.sas:978 */

%macro g2429m(); 10 %mend;
%let g2429before=%sysmacexist(g2429m); %sysmacdelete g2429m;
data g2429o; actual=10+&g2429before+%sysmacexist(g2429m); run;
%symdel g2429before;

data _null_; if 0 then set g2429o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2429 rows=' rows;
else do; set g2429o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND5_PASS=G2429';
else put 'ERROR: ROUND5_FAIL=G2429 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2429:; quit;
