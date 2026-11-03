/* R586 sql_intersect, N=7; source: SAS-Useful-Codes/Macros/SAS-macros-master/insect.sas:4 */

data r586a; do x=1 to 2*7; output; end; run;
data r586b; do x=7 to 3*7; output; end; run;
proc sql; create table r586c as select x from r586a intersect select x from r586b;
create table r586o as select sum(x) as actual from r586c; quit;

data _null_; if 0 then set r586o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R586 rows=' rows;
else do; set r586o; if not missing(actual) and abs(actual-(84))<=1e-10*max(1,abs(84)) then put 'ROUND2_PASS=R586';
else put 'ERROR: ROUND2_FAIL=R586 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r586:; quit;
