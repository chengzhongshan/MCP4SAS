/* G2425 sysmacexist_after_delete, N=6; source: SAS-Useful-Codes/Macros/SuperLearner.sas:978 */

%macro g2425m(); 6 %mend;
%let g2425before=%sysmacexist(g2425m); %sysmacdelete g2425m;
data g2425o; actual=6+&g2425before+%sysmacexist(g2425m); run;
%symdel g2425before;

data _null_; if 0 then set g2425o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2425 rows=' rows;
else do; set g2425o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND5_PASS=G2425';
else put 'ERROR: ROUND5_FAIL=G2425 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2425:; quit;
