/* T1116 character_format_lookup, N=7; source: SAS-Useful-Codes/Macros/GTL_Templates/customized_heatmap4gene_expression.sas:45 */

proc format library=work; value $t1116f 'A7'='alpha' other='other'; run;
data t1116o; actual=7+100*(put('A7',$t1116f.)='alpha'); run;

data _null_; if 0 then set t1116o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1116 rows=' rows;
else do; set t1116o; if not missing(actual) and abs(actual-(107))<=1e-10*max(1,abs(107)) then put 'ROUND3_PASS=T1116';
else put 'ERROR: ROUND3_FAIL=T1116 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1116:; quit;
proc catalog catalog=work.formats; delete t1116f.formatc; quit;
