/* B3414 datasets_modify_column, N=5; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data b3414a; old=5; run;
proc datasets library=work nolist; modify b3414a; label old='New label'; rename old=new; quit;
data b3414o; length label $40; ds=open('b3414a','i'); num=varnum(ds,'new'); label=varlabel(ds,num); actual=5+num+lengthn(label); rc=close(ds); run;

data _null_; if 0 then set b3414o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3414 rows=' rows;
else do; set b3414o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND7_PASS=B3414';
else put 'ERROR: ROUND7_FAIL=B3414 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3414:; quit;
