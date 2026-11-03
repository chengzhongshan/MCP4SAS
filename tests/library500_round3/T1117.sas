/* T1117 character_format_lookup, N=8; source: SAS-Useful-Codes/Macros/GTL_Templates/customized_heatmap4gene_expression.sas:45 */

proc format library=work; value $t1117f 'A8'='alpha' other='other'; run;
data t1117o; actual=8+100*(put('A8',$t1117f.)='alpha'); run;

data _null_; if 0 then set t1117o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1117 rows=' rows;
else do; set t1117o; if not missing(actual) and abs(actual-(108))<=1e-10*max(1,abs(108)) then put 'ROUND3_PASS=T1117';
else put 'ERROR: ROUND3_FAIL=T1117 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1117:; quit;
proc catalog catalog=work.formats; delete t1117f.formatc; quit;
