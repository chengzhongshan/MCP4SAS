/* G2131 update_nomissingcheck, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data g2131a; do k=1 to 2; value=10*k; output; end; run;
data g2131b; do k=1 to 2; value=.; output; end; run;
data g2131c; update g2131a g2131b updatemode=nomissingcheck; by k; run;
proc sql; create table g2131o as select sum(missing(value)) as actual from g2131c; quit;

data _null_; if 0 then set g2131o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2131 rows=' rows;
else do; set g2131o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2131';
else put 'ERROR: ROUND5_FAIL=G2131 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2131:; quit;
