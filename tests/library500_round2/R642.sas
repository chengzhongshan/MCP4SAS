/* R642 sql_update, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data r642a; do x=1 to 3; value=x; output; end; run;
proc sql; update r642a set value=value+10 where mod(x,2)=0;
create table r642o as select sum(value) as actual from r642a; quit;

data _null_; if 0 then set r642o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R642 rows=' rows;
else do; set r642o; if not missing(actual) and abs(actual-(16))<=1e-10*max(1,abs(16)) then put 'ROUND2_PASS=R642';
else put 'ERROR: ROUND2_FAIL=R642 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r642:; quit;
