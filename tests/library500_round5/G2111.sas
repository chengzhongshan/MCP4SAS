/* G2111 modify_remove, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_plotting_both_CNVs_and_SNVs.sas:104 */

data g2111a; do k=1 to 2*2; output; end; run;
data g2111a; modify g2111a; if mod(k,2)=0 then remove; run;
proc sql; create table g2111o as select sum(k) as actual from g2111a; quit;

data _null_; if 0 then set g2111o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2111 rows=' rows;
else do; set g2111o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND5_PASS=G2111';
else put 'ERROR: ROUND5_FAIL=G2111 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2111:; quit;
