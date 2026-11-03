/* G2128 update_missingcheck, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data g2128a; do k=1 to 9; value=10*k; output; end; run;
data g2128b; do k=1 to 9; value=.; output; end; run;
data g2128c; update g2128a g2128b; by k; run;
proc sql; create table g2128o as select sum(value) as actual from g2128c; quit;

data _null_; if 0 then set g2128o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2128 rows=' rows;
else do; set g2128o; if not missing(actual) and abs(actual-(450))<=1e-9*max(1,abs(450)) then put 'ROUND5_PASS=G2128';
else put 'ERROR: ROUND5_FAIL=G2128 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2128:; quit;
