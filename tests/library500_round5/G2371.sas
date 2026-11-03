/* G2371 nrbquote_resolved_apostrophe, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/nrbquote_will_mask_macro_var_but_resolove_it_later_without_using_unquote.sas:2 */

data _null_; call symputx('g2371raw','O''Brien2','g'); run;
%let g2371quoted=%nrbquote(&g2371raw);
data g2371o; length text $50; text=symget('g2371quoted'); actual=lengthn(text); run;
%symdel g2371raw g2371quoted;

data _null_; if 0 then set g2371o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2371 rows=' rows;
else do; set g2371o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2371';
else put 'ERROR: ROUND5_FAIL=G2371 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2371:; quit;
