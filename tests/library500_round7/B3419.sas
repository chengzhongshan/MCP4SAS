/* B3419 datasets_modify_column, N=10; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data b3419a; old=10; run;
proc datasets library=work nolist; modify b3419a; label old='New label'; rename old=new; quit;
data b3419o; length label $40; ds=open('b3419a','i'); num=varnum(ds,'new'); label=varlabel(ds,num); actual=10+num+lengthn(label); rc=close(ds); run;

data _null_; if 0 then set b3419o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3419 rows=' rows;
else do; set b3419o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND7_PASS=B3419';
else put 'ERROR: ROUND7_FAIL=B3419 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3419:; quit;
