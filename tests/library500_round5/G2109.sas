/* G2109 modify_replace, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_plotting_both_CNVs_and_SNVs.sas:104 */

data g2109a; do k=1 to 10; value=k; output; end; run;
data g2109a; modify g2109a; value=2*value; replace; run;
proc sql; create table g2109o as select sum(value) as actual from g2109a; quit;

data _null_; if 0 then set g2109o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2109 rows=' rows;
else do; set g2109o; if not missing(actual) and abs(actual-(110))<=1e-9*max(1,abs(110)) then put 'ROUND5_PASS=G2109';
else put 'ERROR: ROUND5_FAIL=G2109 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2109:; quit;
