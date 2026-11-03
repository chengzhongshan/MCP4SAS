/* B3420 datasets_modify_column, N=11; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data b3420a; old=11; run;
proc datasets library=work nolist; modify b3420a; label old='New label'; rename old=new; quit;
data b3420o; length label $40; ds=open('b3420a','i'); num=varnum(ds,'new'); label=varlabel(ds,num); actual=11+num+lengthn(label); rc=close(ds); run;

data _null_; if 0 then set b3420o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3420 rows=' rows;
else do; set b3420o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND7_PASS=B3420';
else put 'ERROR: ROUND7_FAIL=B3420 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3420:; quit;
