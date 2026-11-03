/* H2620 call_prxposn_offsets, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2620o; length text $40; text='ID=11'; re=prxparse('/ID=([0-9]+)/'); matched=prxmatch(re,text); call prxposn(re,1,pos,len); actual=10*pos+len; call prxfree(re); run;

data _null_; if 0 then set h2620o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2620 rows=' rows;
else do; set h2620o; if not missing(actual) and abs(actual-(42))<=1e-9*max(1,abs(42)) then put 'ROUND6_PASS=H2620';
else put 'ERROR: ROUND6_FAIL=H2620 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2620:; quit;
