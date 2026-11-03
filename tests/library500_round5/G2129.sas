/* G2129 update_missingcheck, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data g2129a; do k=1 to 10; value=10*k; output; end; run;
data g2129b; do k=1 to 10; value=.; output; end; run;
data g2129c; update g2129a g2129b; by k; run;
proc sql; create table g2129o as select sum(value) as actual from g2129c; quit;

data _null_; if 0 then set g2129o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2129 rows=' rows;
else do; set g2129o; if not missing(actual) and abs(actual-(550))<=1e-9*max(1,abs(550)) then put 'ROUND5_PASS=G2129';
else put 'ERROR: ROUND5_FAIL=G2129 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2129:; quit;
