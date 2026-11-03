/* T1113 character_format_lookup, N=4; source: SAS-Useful-Codes/Macros/GTL_Templates/customized_heatmap4gene_expression.sas:45 */

proc format library=work; value $t1113f 'A4'='alpha' other='other'; run;
data t1113o; actual=4+100*(put('A4',$t1113f.)='alpha'); run;

data _null_; if 0 then set t1113o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1113 rows=' rows;
else do; set t1113o; if not missing(actual) and abs(actual-(104))<=1e-10*max(1,abs(104)) then put 'ROUND3_PASS=T1113';
else put 'ERROR: ROUND3_FAIL=T1113 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1113:; quit;
proc catalog catalog=work.formats; delete t1113f.formatc; quit;
