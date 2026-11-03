/* G2372 nrbquote_resolved_apostrophe, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/nrbquote_will_mask_macro_var_but_resolove_it_later_without_using_unquote.sas:2 */

data _null_; call symputx('g2372raw','O''Brien3','g'); run;
%let g2372quoted=%nrbquote(&g2372raw);
data g2372o; length text $50; text=symget('g2372quoted'); actual=lengthn(text); run;
%symdel g2372raw g2372quoted;

data _null_; if 0 then set g2372o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2372 rows=' rows;
else do; set g2372o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2372';
else put 'ERROR: ROUND5_FAIL=G2372 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2372:; quit;
