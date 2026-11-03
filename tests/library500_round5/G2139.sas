/* G2139 update_nomissingcheck, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data g2139a; do k=1 to 10; value=10*k; output; end; run;
data g2139b; do k=1 to 10; value=.; output; end; run;
data g2139c; update g2139a g2139b updatemode=nomissingcheck; by k; run;
proc sql; create table g2139o as select sum(missing(value)) as actual from g2139c; quit;

data _null_; if 0 then set g2139o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2139 rows=' rows;
else do; set g2139o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND5_PASS=G2139';
else put 'ERROR: ROUND5_FAIL=G2139 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2139:; quit;
