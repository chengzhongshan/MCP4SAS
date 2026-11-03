/* H2626 call_prxnext_all_matches, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2626o; length text $80; text='1 7 8'; re=prxparse('/[0-9]+/'); start=1; stop=lengthn(text); actual=0;
call prxnext(re,start,stop,text,pos,len); do while(pos>0); actual=actual+input(substr(text,pos,len),best32.); call prxnext(re,start,stop,text,pos,len); end; call prxfree(re); run;

data _null_; if 0 then set h2626o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2626 rows=' rows;
else do; set h2626o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND6_PASS=H2626';
else put 'ERROR: ROUND6_FAIL=H2626 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2626:; quit;
