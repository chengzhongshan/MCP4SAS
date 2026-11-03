/* R568 sql_union_all, N=9; source: SAS-Useful-Codes/Macros/GTL_Templates/heatmap_with_clusters.old.not_good.sas:36 */

data r568a; do x=1 to 9; output; end; run;
proc sql; create table r568c as select x from r568a union all select x from r568a;
create table r568o as select sum(x) as actual from r568c; quit;

data _null_; if 0 then set r568o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R568 rows=' rows;
else do; set r568o; if not missing(actual) and abs(actual-(90))<=1e-10*max(1,abs(90)) then put 'ROUND2_PASS=R568';
else put 'ERROR: ROUND2_FAIL=R568 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r568:; quit;
