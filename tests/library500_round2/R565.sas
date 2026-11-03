/* R565 sql_union_all, N=6; source: SAS-Useful-Codes/Macros/GTL_Templates/heatmap_with_clusters.old.not_good.sas:36 */

data r565a; do x=1 to 6; output; end; run;
proc sql; create table r565c as select x from r565a union all select x from r565a;
create table r565o as select sum(x) as actual from r565c; quit;

data _null_; if 0 then set r565o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R565 rows=' rows;
else do; set r565o; if not missing(actual) and abs(actual-(42))<=1e-10*max(1,abs(42)) then put 'ROUND2_PASS=R565';
else put 'ERROR: ROUND2_FAIL=R565 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r565:; quit;
