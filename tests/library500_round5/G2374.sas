/* G2374 nrbquote_resolved_apostrophe, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/nrbquote_will_mask_macro_var_but_resolove_it_later_without_using_unquote.sas:2 */

data _null_; call symputx('g2374raw','O''Brien5','g'); run;
%let g2374quoted=%nrbquote(&g2374raw);
data g2374o; length text $50; text=symget('g2374quoted'); actual=lengthn(text); run;
%symdel g2374raw g2374quoted;

data _null_; if 0 then set g2374o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2374 rows=' rows;
else do; set g2374o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2374';
else put 'ERROR: ROUND5_FAIL=G2374 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2374:; quit;
