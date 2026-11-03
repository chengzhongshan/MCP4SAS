/* R624 sql_correlated_max, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Lattice_gscatter_over_bed_track_debug_and_optimization.sas:40 */

data r624a; do k=1 to 5; do v=1 to k; output; end; end; run;
proc sql; create table r624o as select sum(v) as actual from r624a a where v=(select max(v) from r624a b where a.k=b.k); quit;

data _null_; if 0 then set r624o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R624 rows=' rows;
else do; set r624o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND2_PASS=R624';
else put 'ERROR: ROUND2_FAIL=R624 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r624:; quit;
