/* B3411 datasets_modify_column, N=2; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data b3411a; old=2; run;
proc datasets library=work nolist; modify b3411a; label old='New label'; rename old=new; quit;
data b3411o; length label $40; ds=open('b3411a','i'); num=varnum(ds,'new'); label=varlabel(ds,num); actual=2+num+lengthn(label); rc=close(ds); run;

data _null_; if 0 then set b3411o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3411 rows=' rows;
else do; set b3411o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND7_PASS=B3411';
else put 'ERROR: ROUND7_FAIL=B3411 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3411:; quit;
