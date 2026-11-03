/* G2375 nrbquote_resolved_apostrophe, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/nrbquote_will_mask_macro_var_but_resolove_it_later_without_using_unquote.sas:2 */

data _null_; call symputx('g2375raw','O''Brien6','g'); run;
%let g2375quoted=%nrbquote(&g2375raw);
data g2375o; length text $50; text=symget('g2375quoted'); actual=lengthn(text); run;
%symdel g2375raw g2375quoted;

data _null_; if 0 then set g2375o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2375 rows=' rows;
else do; set g2375o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2375';
else put 'ERROR: ROUND5_FAIL=G2375 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2375:; quit;
