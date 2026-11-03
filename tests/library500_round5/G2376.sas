/* G2376 nrbquote_resolved_apostrophe, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/nrbquote_will_mask_macro_var_but_resolove_it_later_without_using_unquote.sas:2 */

data _null_; call symputx('g2376raw','O''Brien7','g'); run;
%let g2376quoted=%nrbquote(&g2376raw);
data g2376o; length text $50; text=symget('g2376quoted'); actual=lengthn(text); run;
%symdel g2376raw g2376quoted;

data _null_; if 0 then set g2376o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2376 rows=' rows;
else do; set g2376o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2376';
else put 'ERROR: ROUND5_FAIL=G2376 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2376:; quit;
