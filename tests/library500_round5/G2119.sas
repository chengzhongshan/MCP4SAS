/* G2119 modify_remove, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_plotting_both_CNVs_and_SNVs.sas:104 */

data g2119a; do k=1 to 2*10; output; end; run;
data g2119a; modify g2119a; if mod(k,2)=0 then remove; run;
proc sql; create table g2119o as select sum(k) as actual from g2119a; quit;

data _null_; if 0 then set g2119o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2119 rows=' rows;
else do; set g2119o; if not missing(actual) and abs(actual-(100))<=1e-9*max(1,abs(100)) then put 'ROUND5_PASS=G2119';
else put 'ERROR: ROUND5_FAIL=G2119 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2119:; quit;
