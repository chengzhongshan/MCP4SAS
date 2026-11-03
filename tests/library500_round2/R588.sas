/* R588 sql_intersect, N=9; source: SAS-Useful-Codes/Macros/SAS-macros-master/insect.sas:4 */

data r588a; do x=1 to 2*9; output; end; run;
data r588b; do x=9 to 3*9; output; end; run;
proc sql; create table r588c as select x from r588a intersect select x from r588b;
create table r588o as select sum(x) as actual from r588c; quit;

data _null_; if 0 then set r588o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R588 rows=' rows;
else do; set r588o; if not missing(actual) and abs(actual-(135))<=1e-10*max(1,abs(135)) then put 'ROUND2_PASS=R588';
else put 'ERROR: ROUND2_FAIL=R588 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r588:; quit;
