/* G2162 sort_dupout, N=3; source: SAS-Useful-Codes/Macros/HpmixArray.sas:628 */

data g2162a; do k=1 to 3; do value=1 to 3; output; end; end; run;
proc sort data=g2162a out=g2162b dupout=g2162c nodupkey equals; by k; run;
proc sql; create table g2162o as select count(*) as actual from g2162c; quit;

data _null_; if 0 then set g2162o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2162 rows=' rows;
else do; set g2162o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND5_PASS=G2162';
else put 'ERROR: ROUND5_FAIL=G2162 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2162:; quit;
