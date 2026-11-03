/* G2110 modify_replace, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_plotting_both_CNVs_and_SNVs.sas:104 */

data g2110a; do k=1 to 11; value=k; output; end; run;
data g2110a; modify g2110a; value=2*value; replace; run;
proc sql; create table g2110o as select sum(value) as actual from g2110a; quit;

data _null_; if 0 then set g2110o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2110 rows=' rows;
else do; set g2110o; if not missing(actual) and abs(actual-(132))<=1e-9*max(1,abs(132)) then put 'ROUND5_PASS=G2110';
else put 'ERROR: ROUND5_FAIL=G2110 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2110:; quit;
