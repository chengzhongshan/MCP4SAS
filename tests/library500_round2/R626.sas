/* R626 sql_correlated_max, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Lattice_gscatter_over_bed_track_debug_and_optimization.sas:40 */

data r626a; do k=1 to 7; do v=1 to k; output; end; end; run;
proc sql; create table r626o as select sum(v) as actual from r626a a where v=(select max(v) from r626a b where a.k=b.k); quit;

data _null_; if 0 then set r626o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R626 rows=' rows;
else do; set r626o; if not missing(actual) and abs(actual-(28))<=1e-10*max(1,abs(28)) then put 'ROUND2_PASS=R626';
else put 'ERROR: ROUND2_FAIL=R626 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r626:; quit;
