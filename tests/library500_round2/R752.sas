/* R752 nobs_metadata, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:34 */

data r752a; do x=1 to 3; output; end; run;
data r752o; if 0 then set r752a nobs=number; actual=number; output; stop; run;

data _null_; if 0 then set r752o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R752 rows=' rows;
else do; set r752o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND2_PASS=R752';
else put 'ERROR: ROUND2_FAIL=R752 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r752:; quit;
