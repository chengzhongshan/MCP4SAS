/* G2132 update_nomissingcheck, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data g2132a; do k=1 to 3; value=10*k; output; end; run;
data g2132b; do k=1 to 3; value=.; output; end; run;
data g2132c; update g2132a g2132b updatemode=nomissingcheck; by k; run;
proc sql; create table g2132o as select sum(missing(value)) as actual from g2132c; quit;

data _null_; if 0 then set g2132o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2132 rows=' rows;
else do; set g2132o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2132';
else put 'ERROR: ROUND5_FAIL=G2132 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2132:; quit;
