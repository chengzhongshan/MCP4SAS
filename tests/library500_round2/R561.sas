/* R561 sql_union_all, N=2; source: SAS-Useful-Codes/Macros/GTL_Templates/heatmap_with_clusters.old.not_good.sas:36 */

data r561a; do x=1 to 2; output; end; run;
proc sql; create table r561c as select x from r561a union all select x from r561a;
create table r561o as select sum(x) as actual from r561c; quit;

data _null_; if 0 then set r561o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R561 rows=' rows;
else do; set r561o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND2_PASS=R561';
else put 'ERROR: ROUND2_FAIL=R561 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r561:; quit;
