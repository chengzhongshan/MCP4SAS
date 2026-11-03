/* G2134 update_nomissingcheck, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data g2134a; do k=1 to 5; value=10*k; output; end; run;
data g2134b; do k=1 to 5; value=.; output; end; run;
data g2134c; update g2134a g2134b updatemode=nomissingcheck; by k; run;
proc sql; create table g2134o as select sum(missing(value)) as actual from g2134c; quit;

data _null_; if 0 then set g2134o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2134 rows=' rows;
else do; set g2134o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2134';
else put 'ERROR: ROUND5_FAIL=G2134 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2134:; quit;
