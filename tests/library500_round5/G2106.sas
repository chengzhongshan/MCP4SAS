/* G2106 modify_replace, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_plotting_both_CNVs_and_SNVs.sas:104 */

data g2106a; do k=1 to 7; value=k; output; end; run;
data g2106a; modify g2106a; value=2*value; replace; run;
proc sql; create table g2106o as select sum(value) as actual from g2106a; quit;

data _null_; if 0 then set g2106o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2106 rows=' rows;
else do; set g2106o; if not missing(actual) and abs(actual-(56))<=1e-9*max(1,abs(56)) then put 'ROUND5_PASS=G2106';
else put 'ERROR: ROUND5_FAIL=G2106 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2106:; quit;
