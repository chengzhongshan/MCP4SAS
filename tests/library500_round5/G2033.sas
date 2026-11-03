/* G2033 exist_data_and_view, N=4; source: SAS-Useful-Codes/Macros/Boxplots4GenesInGTExV8.sas:18 */

data g2033a; x=4; run;
proc sql; create view g2033v as select * from g2033a; quit;
data g2033o; actual=4+exist('g2033a','DATA')+exist('g2033v','VIEW'); run;
proc sql; drop view g2033v; quit;

data _null_; if 0 then set g2033o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2033 rows=' rows;
else do; set g2033o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND5_PASS=G2033';
else put 'ERROR: ROUND5_FAIL=G2033 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2033:; quit;
