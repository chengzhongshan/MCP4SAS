/* R991 fileref_include, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_after_modification.sas:2 */

filename rtemp temp;
data _null_; file rtemp; put 'data r991o; actual=2*7; run;'; run;
%include rtemp;
filename rtemp clear;

data _null_; if 0 then set r991o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R991 rows=' rows;
else do; set r991o; if not missing(actual) and abs(actual-(14))<=1e-10*max(1,abs(14)) then put 'ROUND2_PASS=R991';
else put 'ERROR: ROUND2_FAIL=R991 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r991:; quit;
