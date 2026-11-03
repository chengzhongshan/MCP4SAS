/* H2639 call_prxsubstr_span, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2639o; length text $40; text='xxabc10yy'; re=prxparse('/abc[0-9]+/'); call prxsubstr(re,text,pos,len); actual=10*pos+len; call prxfree(re); run;

data _null_; if 0 then set h2639o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2639 rows=' rows;
else do; set h2639o; if not missing(actual) and abs(actual-(35))<=1e-9*max(1,abs(35)) then put 'ROUND6_PASS=H2639';
else put 'ERROR: ROUND6_FAIL=H2639 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2639:; quit;
