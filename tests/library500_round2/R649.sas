/* R649 sql_update, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data r649a; do x=1 to 10; value=x; output; end; run;
proc sql; update r649a set value=value+10 where mod(x,2)=0;
create table r649o as select sum(value) as actual from r649a; quit;

data _null_; if 0 then set r649o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R649 rows=' rows;
else do; set r649o; if not missing(actual) and abs(actual-(105))<=1e-10*max(1,abs(105)) then put 'ROUND2_PASS=R649';
else put 'ERROR: ROUND2_FAIL=R649 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r649:; quit;
