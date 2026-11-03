/* G2130 update_missingcheck, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data g2130a; do k=1 to 11; value=10*k; output; end; run;
data g2130b; do k=1 to 11; value=.; output; end; run;
data g2130c; update g2130a g2130b; by k; run;
proc sql; create table g2130o as select sum(value) as actual from g2130c; quit;

data _null_; if 0 then set g2130o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2130 rows=' rows;
else do; set g2130o; if not missing(actual) and abs(actual-(660))<=1e-9*max(1,abs(660)) then put 'ROUND5_PASS=G2130';
else put 'ERROR: ROUND5_FAIL=G2130 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2130:; quit;
