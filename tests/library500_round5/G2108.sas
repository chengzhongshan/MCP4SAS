/* G2108 modify_replace, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_plotting_both_CNVs_and_SNVs.sas:104 */

data g2108a; do k=1 to 9; value=k; output; end; run;
data g2108a; modify g2108a; value=2*value; replace; run;
proc sql; create table g2108o as select sum(value) as actual from g2108a; quit;

data _null_; if 0 then set g2108o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2108 rows=' rows;
else do; set g2108o; if not missing(actual) and abs(actual-(90))<=1e-9*max(1,abs(90)) then put 'ROUND5_PASS=G2108';
else put 'ERROR: ROUND5_FAIL=G2108 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2108:; quit;
