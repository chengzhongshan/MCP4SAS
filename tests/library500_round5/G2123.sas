/* G2123 update_missingcheck, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data g2123a; do k=1 to 4; value=10*k; output; end; run;
data g2123b; do k=1 to 4; value=.; output; end; run;
data g2123c; update g2123a g2123b; by k; run;
proc sql; create table g2123o as select sum(value) as actual from g2123c; quit;

data _null_; if 0 then set g2123o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2123 rows=' rows;
else do; set g2123o; if not missing(actual) and abs(actual-(100))<=1e-9*max(1,abs(100)) then put 'ROUND5_PASS=G2123';
else put 'ERROR: ROUND5_FAIL=G2123 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2123:; quit;
