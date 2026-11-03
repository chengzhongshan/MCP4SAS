/* G2140 update_nomissingcheck, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data g2140a; do k=1 to 11; value=10*k; output; end; run;
data g2140b; do k=1 to 11; value=.; output; end; run;
data g2140c; update g2140a g2140b updatemode=nomissingcheck; by k; run;
proc sql; create table g2140o as select sum(missing(value)) as actual from g2140c; quit;

data _null_; if 0 then set g2140o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2140 rows=' rows;
else do; set g2140o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND5_PASS=G2140';
else put 'ERROR: ROUND5_FAIL=G2140 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2140:; quit;
