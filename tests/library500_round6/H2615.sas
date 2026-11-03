/* H2615 call_prxposn_offsets, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2615o; length text $40; text='ID=6'; re=prxparse('/ID=([0-9]+)/'); matched=prxmatch(re,text); call prxposn(re,1,pos,len); actual=10*pos+len; call prxfree(re); run;

data _null_; if 0 then set h2615o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2615 rows=' rows;
else do; set h2615o; if not missing(actual) and abs(actual-(41))<=1e-9*max(1,abs(41)) then put 'ROUND6_PASS=H2615';
else put 'ERROR: ROUND6_FAIL=H2615 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2615:; quit;
