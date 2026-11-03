/* B3412 datasets_modify_column, N=3; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data b3412a; old=3; run;
proc datasets library=work nolist; modify b3412a; label old='New label'; rename old=new; quit;
data b3412o; length label $40; ds=open('b3412a','i'); num=varnum(ds,'new'); label=varlabel(ds,num); actual=3+num+lengthn(label); rc=close(ds); run;

data _null_; if 0 then set b3412o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3412 rows=' rows;
else do; set b3412o; if not missing(actual) and abs(actual-(13))<=1e-9*max(1,abs(13)) then put 'ROUND7_PASS=B3412';
else put 'ERROR: ROUND7_FAIL=B3412 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3412:; quit;
