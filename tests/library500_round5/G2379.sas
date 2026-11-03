/* G2379 nrbquote_resolved_apostrophe, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/nrbquote_will_mask_macro_var_but_resolove_it_later_without_using_unquote.sas:2 */

data _null_; call symputx('g2379raw','O''Brien10','g'); run;
%let g2379quoted=%nrbquote(&g2379raw);
data g2379o; length text $50; text=symget('g2379quoted'); actual=lengthn(text); run;
%symdel g2379raw g2379quoted;

data _null_; if 0 then set g2379o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2379 rows=' rows;
else do; set g2379o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2379';
else put 'ERROR: ROUND5_FAIL=G2379 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2379:; quit;
