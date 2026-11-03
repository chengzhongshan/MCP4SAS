/* G2122 update_missingcheck, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data g2122a; do k=1 to 3; value=10*k; output; end; run;
data g2122b; do k=1 to 3; value=.; output; end; run;
data g2122c; update g2122a g2122b; by k; run;
proc sql; create table g2122o as select sum(value) as actual from g2122c; quit;

data _null_; if 0 then set g2122o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2122 rows=' rows;
else do; set g2122o; if not missing(actual) and abs(actual-(60))<=1e-9*max(1,abs(60)) then put 'ROUND5_PASS=G2122';
else put 'ERROR: ROUND5_FAIL=G2122 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2122:; quit;
