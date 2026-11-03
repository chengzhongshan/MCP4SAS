/* R646 sql_update, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data r646a; do x=1 to 7; value=x; output; end; run;
proc sql; update r646a set value=value+10 where mod(x,2)=0;
create table r646o as select sum(value) as actual from r646a; quit;

data _null_; if 0 then set r646o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R646 rows=' rows;
else do; set r646o; if not missing(actual) and abs(actual-(58))<=1e-10*max(1,abs(58)) then put 'ROUND2_PASS=R646';
else put 'ERROR: ROUND2_FAIL=R646 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r646:; quit;
