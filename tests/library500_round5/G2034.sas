/* G2034 exist_data_and_view, N=5; source: SAS-Useful-Codes/Macros/Boxplots4GenesInGTExV8.sas:18 */

data g2034a; x=5; run;
proc sql; create view g2034v as select * from g2034a; quit;
data g2034o; actual=5+exist('g2034a','DATA')+exist('g2034v','VIEW'); run;
proc sql; drop view g2034v; quit;

data _null_; if 0 then set g2034o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2034 rows=' rows;
else do; set g2034o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND5_PASS=G2034';
else put 'ERROR: ROUND5_FAIL=G2034 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2034:; quit;
