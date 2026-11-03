/* T1119 character_format_lookup, N=10; source: SAS-Useful-Codes/Macros/GTL_Templates/customized_heatmap4gene_expression.sas:45 */

proc format library=work; value $t1119f 'A10'='alpha' other='other'; run;
data t1119o; actual=10+100*(put('A10',$t1119f.)='alpha'); run;

data _null_; if 0 then set t1119o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1119 rows=' rows;
else do; set t1119o; if not missing(actual) and abs(actual-(110))<=1e-10*max(1,abs(110)) then put 'ROUND3_PASS=T1119';
else put 'ERROR: ROUND3_FAIL=T1119 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1119:; quit;
proc catalog catalog=work.formats; delete t1119f.formatc; quit;
