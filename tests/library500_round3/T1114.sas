/* T1114 character_format_lookup, N=5; source: SAS-Useful-Codes/Macros/GTL_Templates/customized_heatmap4gene_expression.sas:45 */

proc format library=work; value $t1114f 'A5'='alpha' other='other'; run;
data t1114o; actual=5+100*(put('A5',$t1114f.)='alpha'); run;

data _null_; if 0 then set t1114o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1114 rows=' rows;
else do; set t1114o; if not missing(actual) and abs(actual-(105))<=1e-10*max(1,abs(105)) then put 'ROUND3_PASS=T1114';
else put 'ERROR: ROUND3_FAIL=T1114 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1114:; quit;
proc catalog catalog=work.formats; delete t1114f.formatc; quit;
