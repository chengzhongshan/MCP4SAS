/* G2101 modify_replace, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_plotting_both_CNVs_and_SNVs.sas:104 */

data g2101a; do k=1 to 2; value=k; output; end; run;
data g2101a; modify g2101a; value=2*value; replace; run;
proc sql; create table g2101o as select sum(value) as actual from g2101a; quit;

data _null_; if 0 then set g2101o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2101 rows=' rows;
else do; set g2101o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND5_PASS=G2101';
else put 'ERROR: ROUND5_FAIL=G2101 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2101:; quit;
