/* G2373 nrbquote_resolved_apostrophe, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/nrbquote_will_mask_macro_var_but_resolove_it_later_without_using_unquote.sas:2 */

data _null_; call symputx('g2373raw','O''Brien4','g'); run;
%let g2373quoted=%nrbquote(&g2373raw);
data g2373o; length text $50; text=symget('g2373quoted'); actual=lengthn(text); run;
%symdel g2373raw g2373quoted;

data _null_; if 0 then set g2373o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2373 rows=' rows;
else do; set g2373o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2373';
else put 'ERROR: ROUND5_FAIL=G2373 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2373:; quit;
