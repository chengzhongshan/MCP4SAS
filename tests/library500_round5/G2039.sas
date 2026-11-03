/* G2039 exist_data_and_view, N=10; source: SAS-Useful-Codes/Macros/Boxplots4GenesInGTExV8.sas:18 */

data g2039a; x=10; run;
proc sql; create view g2039v as select * from g2039a; quit;
data g2039o; actual=10+exist('g2039a','DATA')+exist('g2039v','VIEW'); run;
proc sql; drop view g2039v; quit;

data _null_; if 0 then set g2039o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2039 rows=' rows;
else do; set g2039o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND5_PASS=G2039';
else put 'ERROR: ROUND5_FAIL=G2039 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2039:; quit;
