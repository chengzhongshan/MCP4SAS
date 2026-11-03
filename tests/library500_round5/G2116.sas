/* G2116 modify_remove, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_plotting_both_CNVs_and_SNVs.sas:104 */

data g2116a; do k=1 to 2*7; output; end; run;
data g2116a; modify g2116a; if mod(k,2)=0 then remove; run;
proc sql; create table g2116o as select sum(k) as actual from g2116a; quit;

data _null_; if 0 then set g2116o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2116 rows=' rows;
else do; set g2116o; if not missing(actual) and abs(actual-(49))<=1e-9*max(1,abs(49)) then put 'ROUND5_PASS=G2116';
else put 'ERROR: ROUND5_FAIL=G2116 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2116:; quit;
