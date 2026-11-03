/* B3413 datasets_modify_column, N=4; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data b3413a; old=4; run;
proc datasets library=work nolist; modify b3413a; label old='New label'; rename old=new; quit;
data b3413o; length label $40; ds=open('b3413a','i'); num=varnum(ds,'new'); label=varlabel(ds,num); actual=4+num+lengthn(label); rc=close(ds); run;

data _null_; if 0 then set b3413o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3413 rows=' rows;
else do; set b3413o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND7_PASS=B3413';
else put 'ERROR: ROUND7_FAIL=B3413 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3413:; quit;
