/* G2377 nrbquote_resolved_apostrophe, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/nrbquote_will_mask_macro_var_but_resolove_it_later_without_using_unquote.sas:2 */

data _null_; call symputx('g2377raw','O''Brien8','g'); run;
%let g2377quoted=%nrbquote(&g2377raw);
data g2377o; length text $50; text=symget('g2377quoted'); actual=lengthn(text); run;
%symdel g2377raw g2377quoted;

data _null_; if 0 then set g2377o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2377 rows=' rows;
else do; set g2377o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2377';
else put 'ERROR: ROUND5_FAIL=G2377 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2377:; quit;
