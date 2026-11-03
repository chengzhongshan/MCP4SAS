/* H2635 call_prxsubstr_span, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2635o; length text $40; text='xxabc6yy'; re=prxparse('/abc[0-9]+/'); call prxsubstr(re,text,pos,len); actual=10*pos+len; call prxfree(re); run;

data _null_; if 0 then set h2635o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2635 rows=' rows;
else do; set h2635o; if not missing(actual) and abs(actual-(34))<=1e-9*max(1,abs(34)) then put 'ROUND6_PASS=H2635';
else put 'ERROR: ROUND6_FAIL=H2635 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2635:; quit;
