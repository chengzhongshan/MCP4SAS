/* G2380 nrbquote_resolved_apostrophe, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/nrbquote_will_mask_macro_var_but_resolove_it_later_without_using_unquote.sas:2 */

data _null_; call symputx('g2380raw','O''Brien11','g'); run;
%let g2380quoted=%nrbquote(&g2380raw);
data g2380o; length text $50; text=symget('g2380quoted'); actual=lengthn(text); run;
%symdel g2380raw g2380quoted;

data _null_; if 0 then set g2380o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2380 rows=' rows;
else do; set g2380o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2380';
else put 'ERROR: ROUND5_FAIL=G2380 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2380:; quit;
