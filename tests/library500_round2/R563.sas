/* R563 sql_union_all, N=4; source: SAS-Useful-Codes/Macros/GTL_Templates/heatmap_with_clusters.old.not_good.sas:36 */

data r563a; do x=1 to 4; output; end; run;
proc sql; create table r563c as select x from r563a union all select x from r563a;
create table r563o as select sum(x) as actual from r563c; quit;

data _null_; if 0 then set r563o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R563 rows=' rows;
else do; set r563o; if not missing(actual) and abs(actual-(20))<=1e-10*max(1,abs(20)) then put 'ROUND2_PASS=R563';
else put 'ERROR: ROUND2_FAIL=R563 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r563:; quit;
