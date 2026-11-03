/* G2120 modify_remove, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_plotting_both_CNVs_and_SNVs.sas:104 */

data g2120a; do k=1 to 2*11; output; end; run;
data g2120a; modify g2120a; if mod(k,2)=0 then remove; run;
proc sql; create table g2120o as select sum(k) as actual from g2120a; quit;

data _null_; if 0 then set g2120o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2120 rows=' rows;
else do; set g2120o; if not missing(actual) and abs(actual-(121))<=1e-9*max(1,abs(121)) then put 'ROUND5_PASS=G2120';
else put 'ERROR: ROUND5_FAIL=G2120 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2120:; quit;
