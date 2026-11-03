/* G2118 modify_remove, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_plotting_both_CNVs_and_SNVs.sas:104 */

data g2118a; do k=1 to 2*9; output; end; run;
data g2118a; modify g2118a; if mod(k,2)=0 then remove; run;
proc sql; create table g2118o as select sum(k) as actual from g2118a; quit;

data _null_; if 0 then set g2118o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2118 rows=' rows;
else do; set g2118o; if not missing(actual) and abs(actual-(81))<=1e-9*max(1,abs(81)) then put 'ROUND5_PASS=G2118';
else put 'ERROR: ROUND5_FAIL=G2118 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2118:; quit;
