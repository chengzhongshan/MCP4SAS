/* H2622 call_prxnext_all_matches, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2622o; length text $80; text='1 3 4'; re=prxparse('/[0-9]+/'); start=1; stop=lengthn(text); actual=0;
call prxnext(re,start,stop,text,pos,len); do while(pos>0); actual=actual+input(substr(text,pos,len),best32.); call prxnext(re,start,stop,text,pos,len); end; call prxfree(re); run;

data _null_; if 0 then set h2622o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2622 rows=' rows;
else do; set h2622o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND6_PASS=H2622';
else put 'ERROR: ROUND6_FAIL=H2622 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2622:; quit;
