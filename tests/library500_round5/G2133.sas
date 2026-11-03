/* G2133 update_nomissingcheck, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data g2133a; do k=1 to 4; value=10*k; output; end; run;
data g2133b; do k=1 to 4; value=.; output; end; run;
data g2133c; update g2133a g2133b updatemode=nomissingcheck; by k; run;
proc sql; create table g2133o as select sum(missing(value)) as actual from g2133c; quit;

data _null_; if 0 then set g2133o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2133 rows=' rows;
else do; set g2133o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND5_PASS=G2133';
else put 'ERROR: ROUND5_FAIL=G2133 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2133:; quit;
