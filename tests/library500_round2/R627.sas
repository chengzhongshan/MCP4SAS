/* R627 sql_correlated_max, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Lattice_gscatter_over_bed_track_debug_and_optimization.sas:40 */

data r627a; do k=1 to 8; do v=1 to k; output; end; end; run;
proc sql; create table r627o as select sum(v) as actual from r627a a where v=(select max(v) from r627a b where a.k=b.k); quit;

data _null_; if 0 then set r627o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R627 rows=' rows;
else do; set r627o; if not missing(actual) and abs(actual-(36))<=1e-10*max(1,abs(36)) then put 'ROUND2_PASS=R627';
else put 'ERROR: ROUND2_FAIL=R627 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r627:; quit;
