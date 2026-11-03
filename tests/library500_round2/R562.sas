/* R562 sql_union_all, N=3; source: SAS-Useful-Codes/Macros/GTL_Templates/heatmap_with_clusters.old.not_good.sas:36 */

data r562a; do x=1 to 3; output; end; run;
proc sql; create table r562c as select x from r562a union all select x from r562a;
create table r562o as select sum(x) as actual from r562c; quit;

data _null_; if 0 then set r562o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R562 rows=' rows;
else do; set r562o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND2_PASS=R562';
else put 'ERROR: ROUND2_FAIL=R562 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r562:; quit;
