/* G2127 update_missingcheck, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data g2127a; do k=1 to 8; value=10*k; output; end; run;
data g2127b; do k=1 to 8; value=.; output; end; run;
data g2127c; update g2127a g2127b; by k; run;
proc sql; create table g2127o as select sum(value) as actual from g2127c; quit;

data _null_; if 0 then set g2127o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2127 rows=' rows;
else do; set g2127o; if not missing(actual) and abs(actual-(360))<=1e-9*max(1,abs(360)) then put 'ROUND5_PASS=G2127';
else put 'ERROR: ROUND5_FAIL=G2127 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2127:; quit;
