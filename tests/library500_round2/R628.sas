/* R628 sql_correlated_max, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Lattice_gscatter_over_bed_track_debug_and_optimization.sas:40 */

data r628a; do k=1 to 9; do v=1 to k; output; end; end; run;
proc sql; create table r628o as select sum(v) as actual from r628a a where v=(select max(v) from r628a b where a.k=b.k); quit;

data _null_; if 0 then set r628o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R628 rows=' rows;
else do; set r628o; if not missing(actual) and abs(actual-(45))<=1e-10*max(1,abs(45)) then put 'ROUND2_PASS=R628';
else put 'ERROR: ROUND2_FAIL=R628 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r628:; quit;
