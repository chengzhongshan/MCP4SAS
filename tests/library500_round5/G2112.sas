/* G2112 modify_remove, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_plotting_both_CNVs_and_SNVs.sas:104 */

data g2112a; do k=1 to 2*3; output; end; run;
data g2112a; modify g2112a; if mod(k,2)=0 then remove; run;
proc sql; create table g2112o as select sum(k) as actual from g2112a; quit;

data _null_; if 0 then set g2112o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2112 rows=' rows;
else do; set g2112o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2112';
else put 'ERROR: ROUND5_FAIL=G2112 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2112:; quit;
