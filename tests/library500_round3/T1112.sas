/* T1112 character_format_lookup, N=3; source: SAS-Useful-Codes/Macros/GTL_Templates/customized_heatmap4gene_expression.sas:45 */

proc format library=work; value $t1112f 'A3'='alpha' other='other'; run;
data t1112o; actual=3+100*(put('A3',$t1112f.)='alpha'); run;

data _null_; if 0 then set t1112o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1112 rows=' rows;
else do; set t1112o; if not missing(actual) and abs(actual-(103))<=1e-10*max(1,abs(103)) then put 'ROUND3_PASS=T1112';
else put 'ERROR: ROUND3_FAIL=T1112 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1112:; quit;
proc catalog catalog=work.formats; delete t1112f.formatc; quit;
