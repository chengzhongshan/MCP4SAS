/* R564 sql_union_all, N=5; source: SAS-Useful-Codes/Macros/GTL_Templates/heatmap_with_clusters.old.not_good.sas:36 */

data r564a; do x=1 to 5; output; end; run;
proc sql; create table r564c as select x from r564a union all select x from r564a;
create table r564o as select sum(x) as actual from r564c; quit;

data _null_; if 0 then set r564o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R564 rows=' rows;
else do; set r564o; if not missing(actual) and abs(actual-(30))<=1e-10*max(1,abs(30)) then put 'ROUND2_PASS=R564';
else put 'ERROR: ROUND2_FAIL=R564 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r564:; quit;
