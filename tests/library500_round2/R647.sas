/* R647 sql_update, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data r647a; do x=1 to 8; value=x; output; end; run;
proc sql; update r647a set value=value+10 where mod(x,2)=0;
create table r647o as select sum(value) as actual from r647a; quit;

data _null_; if 0 then set r647o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R647 rows=' rows;
else do; set r647o; if not missing(actual) and abs(actual-(76))<=1e-10*max(1,abs(76)) then put 'ROUND2_PASS=R647';
else put 'ERROR: ROUND2_FAIL=R647 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r647:; quit;
