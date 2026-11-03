/* G2032 exist_data_and_view, N=3; source: SAS-Useful-Codes/Macros/Boxplots4GenesInGTExV8.sas:18 */

data g2032a; x=3; run;
proc sql; create view g2032v as select * from g2032a; quit;
data g2032o; actual=3+exist('g2032a','DATA')+exist('g2032v','VIEW'); run;
proc sql; drop view g2032v; quit;

data _null_; if 0 then set g2032o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2032 rows=' rows;
else do; set g2032o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2032';
else put 'ERROR: ROUND5_FAIL=G2032 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2032:; quit;
