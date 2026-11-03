/* R623 sql_correlated_max, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Lattice_gscatter_over_bed_track_debug_and_optimization.sas:40 */

data r623a; do k=1 to 4; do v=1 to k; output; end; end; run;
proc sql; create table r623o as select sum(v) as actual from r623a a where v=(select max(v) from r623a b where a.k=b.k); quit;

data _null_; if 0 then set r623o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R623 rows=' rows;
else do; set r623o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND2_PASS=R623';
else put 'ERROR: ROUND2_FAIL=R623 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r623:; quit;
