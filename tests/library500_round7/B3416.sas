/* B3416 datasets_modify_column, N=7; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data b3416a; old=7; run;
proc datasets library=work nolist; modify b3416a; label old='New label'; rename old=new; quit;
data b3416o; length label $40; ds=open('b3416a','i'); num=varnum(ds,'new'); label=varlabel(ds,num); actual=7+num+lengthn(label); rc=close(ds); run;

data _null_; if 0 then set b3416o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3416 rows=' rows;
else do; set b3416o; if not missing(actual) and abs(actual-(17))<=1e-9*max(1,abs(17)) then put 'ROUND7_PASS=B3416';
else put 'ERROR: ROUND7_FAIL=B3416 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3416:; quit;
