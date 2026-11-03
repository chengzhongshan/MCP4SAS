/* B3417 datasets_modify_column, N=8; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data b3417a; old=8; run;
proc datasets library=work nolist; modify b3417a; label old='New label'; rename old=new; quit;
data b3417o; length label $40; ds=open('b3417a','i'); num=varnum(ds,'new'); label=varlabel(ds,num); actual=8+num+lengthn(label); rc=close(ds); run;

data _null_; if 0 then set b3417o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3417 rows=' rows;
else do; set b3417o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND7_PASS=B3417';
else put 'ERROR: ROUND7_FAIL=B3417 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3417:; quit;
