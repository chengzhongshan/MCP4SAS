/* T1120 character_format_lookup, N=11; source: SAS-Useful-Codes/Macros/GTL_Templates/customized_heatmap4gene_expression.sas:45 */

proc format library=work; value $t1120f 'A11'='alpha' other='other'; run;
data t1120o; actual=11+100*(put('A11',$t1120f.)='alpha'); run;

data _null_; if 0 then set t1120o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1120 rows=' rows;
else do; set t1120o; if not missing(actual) and abs(actual-(111))<=1e-10*max(1,abs(111)) then put 'ROUND3_PASS=T1120';
else put 'ERROR: ROUND3_FAIL=T1120 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1120:; quit;
proc catalog catalog=work.formats; delete t1120f.formatc; quit;
