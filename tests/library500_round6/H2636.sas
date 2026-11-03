/* H2636 call_prxsubstr_span, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2636o; length text $40; text='xxabc7yy'; re=prxparse('/abc[0-9]+/'); call prxsubstr(re,text,pos,len); actual=10*pos+len; call prxfree(re); run;

data _null_; if 0 then set h2636o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2636 rows=' rows;
else do; set h2636o; if not missing(actual) and abs(actual-(34))<=1e-9*max(1,abs(34)) then put 'ROUND6_PASS=H2636';
else put 'ERROR: ROUND6_FAIL=H2636 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2636:; quit;
