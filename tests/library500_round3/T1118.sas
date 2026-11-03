/* T1118 character_format_lookup, N=9; source: SAS-Useful-Codes/Macros/GTL_Templates/customized_heatmap4gene_expression.sas:45 */

proc format library=work; value $t1118f 'A9'='alpha' other='other'; run;
data t1118o; actual=9+100*(put('A9',$t1118f.)='alpha'); run;

data _null_; if 0 then set t1118o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1118 rows=' rows;
else do; set t1118o; if not missing(actual) and abs(actual-(109))<=1e-10*max(1,abs(109)) then put 'ROUND3_PASS=T1118';
else put 'ERROR: ROUND3_FAIL=T1118 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1118:; quit;
proc catalog catalog=work.formats; delete t1118f.formatc; quit;
