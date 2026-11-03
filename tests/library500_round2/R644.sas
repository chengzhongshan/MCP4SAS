/* R644 sql_update, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data r644a; do x=1 to 5; value=x; output; end; run;
proc sql; update r644a set value=value+10 where mod(x,2)=0;
create table r644o as select sum(value) as actual from r644a; quit;

data _null_; if 0 then set r644o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R644 rows=' rows;
else do; set r644o; if not missing(actual) and abs(actual-(35))<=1e-10*max(1,abs(35)) then put 'ROUND2_PASS=R644';
else put 'ERROR: ROUND2_FAIL=R644 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r644:; quit;
