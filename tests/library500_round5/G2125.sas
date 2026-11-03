/* G2125 update_missingcheck, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data g2125a; do k=1 to 6; value=10*k; output; end; run;
data g2125b; do k=1 to 6; value=.; output; end; run;
data g2125c; update g2125a g2125b; by k; run;
proc sql; create table g2125o as select sum(value) as actual from g2125c; quit;

data _null_; if 0 then set g2125o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2125 rows=' rows;
else do; set g2125o; if not missing(actual) and abs(actual-(210))<=1e-9*max(1,abs(210)) then put 'ROUND5_PASS=G2125';
else put 'ERROR: ROUND5_FAIL=G2125 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2125:; quit;
