/* T1111 character_format_lookup, N=2; source: SAS-Useful-Codes/Macros/GTL_Templates/customized_heatmap4gene_expression.sas:45 */

proc format library=work; value $t1111f 'A2'='alpha' other='other'; run;
data t1111o; actual=2+100*(put('A2',$t1111f.)='alpha'); run;

data _null_; if 0 then set t1111o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1111 rows=' rows;
else do; set t1111o; if not missing(actual) and abs(actual-(102))<=1e-10*max(1,abs(102)) then put 'ROUND3_PASS=T1111';
else put 'ERROR: ROUND3_FAIL=T1111 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1111:; quit;
proc catalog catalog=work.formats; delete t1111f.formatc; quit;
