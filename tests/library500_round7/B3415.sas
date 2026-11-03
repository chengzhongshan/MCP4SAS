/* B3415 datasets_modify_column, N=6; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data b3415a; old=6; run;
proc datasets library=work nolist; modify b3415a; label old='New label'; rename old=new; quit;
data b3415o; length label $40; ds=open('b3415a','i'); num=varnum(ds,'new'); label=varlabel(ds,num); actual=6+num+lengthn(label); rc=close(ds); run;

data _null_; if 0 then set b3415o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3415 rows=' rows;
else do; set b3415o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND7_PASS=B3415';
else put 'ERROR: ROUND7_FAIL=B3415 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3415:; quit;
