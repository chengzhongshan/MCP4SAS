/* R643 sql_update, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data r643a; do x=1 to 4; value=x; output; end; run;
proc sql; update r643a set value=value+10 where mod(x,2)=0;
create table r643o as select sum(value) as actual from r643a; quit;

data _null_; if 0 then set r643o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R643 rows=' rows;
else do; set r643o; if not missing(actual) and abs(actual-(30))<=1e-10*max(1,abs(30)) then put 'ROUND2_PASS=R643';
else put 'ERROR: ROUND2_FAIL=R643 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r643:; quit;
