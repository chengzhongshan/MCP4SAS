/* G2136 update_nomissingcheck, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data g2136a; do k=1 to 7; value=10*k; output; end; run;
data g2136b; do k=1 to 7; value=.; output; end; run;
data g2136c; update g2136a g2136b updatemode=nomissingcheck; by k; run;
proc sql; create table g2136o as select sum(missing(value)) as actual from g2136c; quit;

data _null_; if 0 then set g2136o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2136 rows=' rows;
else do; set g2136o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND5_PASS=G2136';
else put 'ERROR: ROUND5_FAIL=G2136 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2136:; quit;
