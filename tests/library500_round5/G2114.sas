/* G2114 modify_remove, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_plotting_both_CNVs_and_SNVs.sas:104 */

data g2114a; do k=1 to 2*5; output; end; run;
data g2114a; modify g2114a; if mod(k,2)=0 then remove; run;
proc sql; create table g2114o as select sum(k) as actual from g2114a; quit;

data _null_; if 0 then set g2114o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2114 rows=' rows;
else do; set g2114o; if not missing(actual) and abs(actual-(25))<=1e-9*max(1,abs(25)) then put 'ROUND5_PASS=G2114';
else put 'ERROR: ROUND5_FAIL=G2114 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2114:; quit;
