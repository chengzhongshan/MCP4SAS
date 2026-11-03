/* R566 sql_union_all, N=7; source: SAS-Useful-Codes/Macros/GTL_Templates/heatmap_with_clusters.old.not_good.sas:36 */

data r566a; do x=1 to 7; output; end; run;
proc sql; create table r566c as select x from r566a union all select x from r566a;
create table r566o as select sum(x) as actual from r566c; quit;

data _null_; if 0 then set r566o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R566 rows=' rows;
else do; set r566o; if not missing(actual) and abs(actual-(56))<=1e-10*max(1,abs(56)) then put 'ROUND2_PASS=R566';
else put 'ERROR: ROUND2_FAIL=R566 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r566:; quit;
