/* G2038 exist_data_and_view, N=9; source: SAS-Useful-Codes/Macros/Boxplots4GenesInGTExV8.sas:18 */

data g2038a; x=9; run;
proc sql; create view g2038v as select * from g2038a; quit;
data g2038o; actual=9+exist('g2038a','DATA')+exist('g2038v','VIEW'); run;
proc sql; drop view g2038v; quit;

data _null_; if 0 then set g2038o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2038 rows=' rows;
else do; set g2038o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND5_PASS=G2038';
else put 'ERROR: ROUND5_FAIL=G2038 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2038:; quit;
