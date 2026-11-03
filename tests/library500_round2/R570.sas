/* R570 sql_union_all, N=11; source: SAS-Useful-Codes/Macros/GTL_Templates/heatmap_with_clusters.old.not_good.sas:36 */

data r570a; do x=1 to 11; output; end; run;
proc sql; create table r570c as select x from r570a union all select x from r570a;
create table r570o as select sum(x) as actual from r570c; quit;

data _null_; if 0 then set r570o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R570 rows=' rows;
else do; set r570o; if not missing(actual) and abs(actual-(132))<=1e-10*max(1,abs(132)) then put 'ROUND2_PASS=R570';
else put 'ERROR: ROUND2_FAIL=R570 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r570:; quit;
