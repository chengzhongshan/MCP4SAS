/* G2126 update_missingcheck, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data g2126a; do k=1 to 7; value=10*k; output; end; run;
data g2126b; do k=1 to 7; value=.; output; end; run;
data g2126c; update g2126a g2126b; by k; run;
proc sql; create table g2126o as select sum(value) as actual from g2126c; quit;

data _null_; if 0 then set g2126o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2126 rows=' rows;
else do; set g2126o; if not missing(actual) and abs(actual-(280))<=1e-9*max(1,abs(280)) then put 'ROUND5_PASS=G2126';
else put 'ERROR: ROUND5_FAIL=G2126 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2126:; quit;
