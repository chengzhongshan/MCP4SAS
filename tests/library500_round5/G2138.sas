/* G2138 update_nomissingcheck, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data g2138a; do k=1 to 9; value=10*k; output; end; run;
data g2138b; do k=1 to 9; value=.; output; end; run;
data g2138c; update g2138a g2138b updatemode=nomissingcheck; by k; run;
proc sql; create table g2138o as select sum(missing(value)) as actual from g2138c; quit;

data _null_; if 0 then set g2138o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2138 rows=' rows;
else do; set g2138o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2138';
else put 'ERROR: ROUND5_FAIL=G2138 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2138:; quit;
