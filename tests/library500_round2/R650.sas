/* R650 sql_update, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data r650a; do x=1 to 11; value=x; output; end; run;
proc sql; update r650a set value=value+10 where mod(x,2)=0;
create table r650o as select sum(value) as actual from r650a; quit;

data _null_; if 0 then set r650o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R650 rows=' rows;
else do; set r650o; if not missing(actual) and abs(actual-(116))<=1e-10*max(1,abs(116)) then put 'ROUND2_PASS=R650';
else put 'ERROR: ROUND2_FAIL=R650 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r650:; quit;
