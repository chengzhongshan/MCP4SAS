/* R622 sql_correlated_max, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Lattice_gscatter_over_bed_track_debug_and_optimization.sas:40 */

data r622a; do k=1 to 3; do v=1 to k; output; end; end; run;
proc sql; create table r622o as select sum(v) as actual from r622a a where v=(select max(v) from r622a b where a.k=b.k); quit;

data _null_; if 0 then set r622o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R622 rows=' rows;
else do; set r622o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND2_PASS=R622';
else put 'ERROR: ROUND2_FAIL=R622 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r622:; quit;
