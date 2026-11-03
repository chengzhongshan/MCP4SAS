/* R629 sql_correlated_max, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Lattice_gscatter_over_bed_track_debug_and_optimization.sas:40 */

data r629a; do k=1 to 10; do v=1 to k; output; end; end; run;
proc sql; create table r629o as select sum(v) as actual from r629a a where v=(select max(v) from r629a b where a.k=b.k); quit;

data _null_; if 0 then set r629o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R629 rows=' rows;
else do; set r629o; if not missing(actual) and abs(actual-(55))<=1e-10*max(1,abs(55)) then put 'ROUND2_PASS=R629';
else put 'ERROR: ROUND2_FAIL=R629 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r629:; quit;
