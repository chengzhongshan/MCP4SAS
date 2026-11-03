/* R641 sql_update, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data r641a; do x=1 to 2; value=x; output; end; run;
proc sql; update r641a set value=value+10 where mod(x,2)=0;
create table r641o as select sum(value) as actual from r641a; quit;

data _null_; if 0 then set r641o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R641 rows=' rows;
else do; set r641o; if not missing(actual) and abs(actual-(13))<=1e-10*max(1,abs(13)) then put 'ROUND2_PASS=R641';
else put 'ERROR: ROUND2_FAIL=R641 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r641:; quit;
