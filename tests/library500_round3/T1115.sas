/* T1115 character_format_lookup, N=6; source: SAS-Useful-Codes/Macros/GTL_Templates/customized_heatmap4gene_expression.sas:45 */

proc format library=work; value $t1115f 'A6'='alpha' other='other'; run;
data t1115o; actual=6+100*(put('A6',$t1115f.)='alpha'); run;

data _null_; if 0 then set t1115o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1115 rows=' rows;
else do; set t1115o; if not missing(actual) and abs(actual-(106))<=1e-10*max(1,abs(106)) then put 'ROUND3_PASS=T1115';
else put 'ERROR: ROUND3_FAIL=T1115 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1115:; quit;
proc catalog catalog=work.formats; delete t1115f.formatc; quit;
