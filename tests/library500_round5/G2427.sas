/* G2427 sysmacexist_after_delete, N=8; source: SAS-Useful-Codes/Macros/SuperLearner.sas:978 */

%macro g2427m(); 8 %mend;
%let g2427before=%sysmacexist(g2427m); %sysmacdelete g2427m;
data g2427o; actual=8+&g2427before+%sysmacexist(g2427m); run;
%symdel g2427before;

data _null_; if 0 then set g2427o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2427 rows=' rows;
else do; set g2427o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2427';
else put 'ERROR: ROUND5_FAIL=G2427 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2427:; quit;
