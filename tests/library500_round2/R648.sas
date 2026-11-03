/* R648 sql_update, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data r648a; do x=1 to 9; value=x; output; end; run;
proc sql; update r648a set value=value+10 where mod(x,2)=0;
create table r648o as select sum(value) as actual from r648a; quit;

data _null_; if 0 then set r648o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R648 rows=' rows;
else do; set r648o; if not missing(actual) and abs(actual-(85))<=1e-10*max(1,abs(85)) then put 'ROUND2_PASS=R648';
else put 'ERROR: ROUND2_FAIL=R648 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r648:; quit;
