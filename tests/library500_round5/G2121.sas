/* G2121 update_missingcheck, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data g2121a; do k=1 to 2; value=10*k; output; end; run;
data g2121b; do k=1 to 2; value=.; output; end; run;
data g2121c; update g2121a g2121b; by k; run;
proc sql; create table g2121o as select sum(value) as actual from g2121c; quit;

data _null_; if 0 then set g2121o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2121 rows=' rows;
else do; set g2121o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND5_PASS=G2121';
else put 'ERROR: ROUND5_FAIL=G2121 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2121:; quit;
