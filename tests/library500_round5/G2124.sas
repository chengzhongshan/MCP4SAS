/* G2124 update_missingcheck, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data g2124a; do k=1 to 5; value=10*k; output; end; run;
data g2124b; do k=1 to 5; value=.; output; end; run;
data g2124c; update g2124a g2124b; by k; run;
proc sql; create table g2124o as select sum(value) as actual from g2124c; quit;

data _null_; if 0 then set g2124o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2124 rows=' rows;
else do; set g2124o; if not missing(actual) and abs(actual-(150))<=1e-9*max(1,abs(150)) then put 'ROUND5_PASS=G2124';
else put 'ERROR: ROUND5_FAIL=G2124 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2124:; quit;
