/* G2113 modify_remove, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_plotting_both_CNVs_and_SNVs.sas:104 */

data g2113a; do k=1 to 2*4; output; end; run;
data g2113a; modify g2113a; if mod(k,2)=0 then remove; run;
proc sql; create table g2113o as select sum(k) as actual from g2113a; quit;

data _null_; if 0 then set g2113o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2113 rows=' rows;
else do; set g2113o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND5_PASS=G2113';
else put 'ERROR: ROUND5_FAIL=G2113 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2113:; quit;
