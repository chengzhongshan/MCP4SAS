/* G2105 modify_replace, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_plotting_both_CNVs_and_SNVs.sas:104 */

data g2105a; do k=1 to 6; value=k; output; end; run;
data g2105a; modify g2105a; value=2*value; replace; run;
proc sql; create table g2105o as select sum(value) as actual from g2105a; quit;

data _null_; if 0 then set g2105o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2105 rows=' rows;
else do; set g2105o; if not missing(actual) and abs(actual-(42))<=1e-9*max(1,abs(42)) then put 'ROUND5_PASS=G2105';
else put 'ERROR: ROUND5_FAIL=G2105 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2105:; quit;
