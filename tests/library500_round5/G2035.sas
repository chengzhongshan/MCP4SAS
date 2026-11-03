/* G2035 exist_data_and_view, N=6; source: SAS-Useful-Codes/Macros/Boxplots4GenesInGTExV8.sas:18 */

data g2035a; x=6; run;
proc sql; create view g2035v as select * from g2035a; quit;
data g2035o; actual=6+exist('g2035a','DATA')+exist('g2035v','VIEW'); run;
proc sql; drop view g2035v; quit;

data _null_; if 0 then set g2035o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2035 rows=' rows;
else do; set g2035o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2035';
else put 'ERROR: ROUND5_FAIL=G2035 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2035:; quit;
