/* B3418 datasets_modify_column, N=9; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data b3418a; old=9; run;
proc datasets library=work nolist; modify b3418a; label old='New label'; rename old=new; quit;
data b3418o; length label $40; ds=open('b3418a','i'); num=varnum(ds,'new'); label=varlabel(ds,num); actual=9+num+lengthn(label); rc=close(ds); run;

data _null_; if 0 then set b3418o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3418 rows=' rows;
else do; set b3418o; if not missing(actual) and abs(actual-(19))<=1e-9*max(1,abs(19)) then put 'ROUND7_PASS=B3418';
else put 'ERROR: ROUND7_FAIL=B3418 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3418:; quit;
