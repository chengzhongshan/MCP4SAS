/* G2036 exist_data_and_view, N=7; source: SAS-Useful-Codes/Macros/Boxplots4GenesInGTExV8.sas:18 */

data g2036a; x=7; run;
proc sql; create view g2036v as select * from g2036a; quit;
data g2036o; actual=7+exist('g2036a','DATA')+exist('g2036v','VIEW'); run;
proc sql; drop view g2036v; quit;

data _null_; if 0 then set g2036o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2036 rows=' rows;
else do; set g2036o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2036';
else put 'ERROR: ROUND5_FAIL=G2036 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2036:; quit;
