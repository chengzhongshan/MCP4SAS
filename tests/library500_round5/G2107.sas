/* G2107 modify_replace, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_plotting_both_CNVs_and_SNVs.sas:104 */

data g2107a; do k=1 to 8; value=k; output; end; run;
data g2107a; modify g2107a; value=2*value; replace; run;
proc sql; create table g2107o as select sum(value) as actual from g2107a; quit;

data _null_; if 0 then set g2107o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2107 rows=' rows;
else do; set g2107o; if not missing(actual) and abs(actual-(72))<=1e-9*max(1,abs(72)) then put 'ROUND5_PASS=G2107';
else put 'ERROR: ROUND5_FAIL=G2107 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2107:; quit;
