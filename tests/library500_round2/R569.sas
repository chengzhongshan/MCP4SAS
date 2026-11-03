/* R569 sql_union_all, N=10; source: SAS-Useful-Codes/Macros/GTL_Templates/heatmap_with_clusters.old.not_good.sas:36 */

data r569a; do x=1 to 10; output; end; run;
proc sql; create table r569c as select x from r569a union all select x from r569a;
create table r569o as select sum(x) as actual from r569c; quit;

data _null_; if 0 then set r569o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R569 rows=' rows;
else do; set r569o; if not missing(actual) and abs(actual-(110))<=1e-10*max(1,abs(110)) then put 'ROUND2_PASS=R569';
else put 'ERROR: ROUND2_FAIL=R569 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r569:; quit;
