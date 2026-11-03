/* G2115 modify_remove, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_plotting_both_CNVs_and_SNVs.sas:104 */

data g2115a; do k=1 to 2*6; output; end; run;
data g2115a; modify g2115a; if mod(k,2)=0 then remove; run;
proc sql; create table g2115o as select sum(k) as actual from g2115a; quit;

data _null_; if 0 then set g2115o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2115 rows=' rows;
else do; set g2115o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND5_PASS=G2115';
else put 'ERROR: ROUND5_FAIL=G2115 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2115:; quit;
