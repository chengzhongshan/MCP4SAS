/* G2031 exist_data_and_view, N=2; source: SAS-Useful-Codes/Macros/Boxplots4GenesInGTExV8.sas:18 */

data g2031a; x=2; run;
proc sql; create view g2031v as select * from g2031a; quit;
data g2031o; actual=2+exist('g2031a','DATA')+exist('g2031v','VIEW'); run;
proc sql; drop view g2031v; quit;

data _null_; if 0 then set g2031o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2031 rows=' rows;
else do; set g2031o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND5_PASS=G2031';
else put 'ERROR: ROUND5_FAIL=G2031 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2031:; quit;
