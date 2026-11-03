/* G2135 update_nomissingcheck, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data g2135a; do k=1 to 6; value=10*k; output; end; run;
data g2135b; do k=1 to 6; value=.; output; end; run;
data g2135c; update g2135a g2135b updatemode=nomissingcheck; by k; run;
proc sql; create table g2135o as select sum(missing(value)) as actual from g2135c; quit;

data _null_; if 0 then set g2135o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2135 rows=' rows;
else do; set g2135o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND5_PASS=G2135';
else put 'ERROR: ROUND5_FAIL=G2135 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2135:; quit;
