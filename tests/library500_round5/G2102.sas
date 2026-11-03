/* G2102 modify_replace, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_plotting_both_CNVs_and_SNVs.sas:104 */

data g2102a; do k=1 to 3; value=k; output; end; run;
data g2102a; modify g2102a; value=2*value; replace; run;
proc sql; create table g2102o as select sum(value) as actual from g2102a; quit;

data _null_; if 0 then set g2102o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2102 rows=' rows;
else do; set g2102o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND5_PASS=G2102';
else put 'ERROR: ROUND5_FAIL=G2102 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2102:; quit;
