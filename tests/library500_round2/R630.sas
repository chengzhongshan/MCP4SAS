/* R630 sql_correlated_max, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Lattice_gscatter_over_bed_track_debug_and_optimization.sas:40 */

data r630a; do k=1 to 11; do v=1 to k; output; end; end; run;
proc sql; create table r630o as select sum(v) as actual from r630a a where v=(select max(v) from r630a b where a.k=b.k); quit;

data _null_; if 0 then set r630o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R630 rows=' rows;
else do; set r630o; if not missing(actual) and abs(actual-(66))<=1e-10*max(1,abs(66)) then put 'ROUND2_PASS=R630';
else put 'ERROR: ROUND2_FAIL=R630 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r630:; quit;
