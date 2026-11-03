/* R567 sql_union_all, N=8; source: SAS-Useful-Codes/Macros/GTL_Templates/heatmap_with_clusters.old.not_good.sas:36 */

data r567a; do x=1 to 8; output; end; run;
proc sql; create table r567c as select x from r567a union all select x from r567a;
create table r567o as select sum(x) as actual from r567c; quit;

data _null_; if 0 then set r567o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R567 rows=' rows;
else do; set r567o; if not missing(actual) and abs(actual-(72))<=1e-10*max(1,abs(72)) then put 'ROUND2_PASS=R567';
else put 'ERROR: ROUND2_FAIL=R567 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r567:; quit;
