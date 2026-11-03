/* G2104 modify_replace, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_plotting_both_CNVs_and_SNVs.sas:104 */

data g2104a; do k=1 to 5; value=k; output; end; run;
data g2104a; modify g2104a; value=2*value; replace; run;
proc sql; create table g2104o as select sum(value) as actual from g2104a; quit;

data _null_; if 0 then set g2104o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2104 rows=' rows;
else do; set g2104o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND5_PASS=G2104';
else put 'ERROR: ROUND5_FAIL=G2104 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2104:; quit;
