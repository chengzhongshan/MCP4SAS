/* G2378 nrbquote_resolved_apostrophe, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/nrbquote_will_mask_macro_var_but_resolove_it_later_without_using_unquote.sas:2 */

data _null_; call symputx('g2378raw','O''Brien9','g'); run;
%let g2378quoted=%nrbquote(&g2378raw);
data g2378o; length text $50; text=symget('g2378quoted'); actual=lengthn(text); run;
%symdel g2378raw g2378quoted;

data _null_; if 0 then set g2378o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2378 rows=' rows;
else do; set g2378o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2378';
else put 'ERROR: ROUND5_FAIL=G2378 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2378:; quit;
