/* G2137 update_nomissingcheck, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data g2137a; do k=1 to 8; value=10*k; output; end; run;
data g2137b; do k=1 to 8; value=.; output; end; run;
data g2137c; update g2137a g2137b updatemode=nomissingcheck; by k; run;
proc sql; create table g2137o as select sum(missing(value)) as actual from g2137c; quit;

data _null_; if 0 then set g2137o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2137 rows=' rows;
else do; set g2137o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2137';
else put 'ERROR: ROUND5_FAIL=G2137 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2137:; quit;
