/* H2614 call_prxposn_offsets, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2614o; length text $40; text='ID=5'; re=prxparse('/ID=([0-9]+)/'); matched=prxmatch(re,text); call prxposn(re,1,pos,len); actual=10*pos+len; call prxfree(re); run;

data _null_; if 0 then set h2614o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2614 rows=' rows;
else do; set h2614o; if not missing(actual) and abs(actual-(41))<=1e-9*max(1,abs(41)) then put 'ROUND6_PASS=H2614';
else put 'ERROR: ROUND6_FAIL=H2614 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2614:; quit;
