/* G2117 modify_remove, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_plotting_both_CNVs_and_SNVs.sas:104 */

data g2117a; do k=1 to 2*8; output; end; run;
data g2117a; modify g2117a; if mod(k,2)=0 then remove; run;
proc sql; create table g2117o as select sum(k) as actual from g2117a; quit;

data _null_; if 0 then set g2117o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2117 rows=' rows;
else do; set g2117o; if not missing(actual) and abs(actual-(64))<=1e-9*max(1,abs(64)) then put 'ROUND5_PASS=G2117';
else put 'ERROR: ROUND5_FAIL=G2117 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2117:; quit;
