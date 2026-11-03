/* R621 sql_correlated_max, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Lattice_gscatter_over_bed_track_debug_and_optimization.sas:40 */

data r621a; do k=1 to 2; do v=1 to k; output; end; end; run;
proc sql; create table r621o as select sum(v) as actual from r621a a where v=(select max(v) from r621a b where a.k=b.k); quit;

data _null_; if 0 then set r621o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R621 rows=' rows;
else do; set r621o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND2_PASS=R621';
else put 'ERROR: ROUND2_FAIL=R621 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r621:; quit;
