/* R997 fileref_include, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_after_modification.sas:2 */

filename rtemp temp;
data _null_; file rtemp; put 'data r997o; actual=8*7; run;'; run;
%include rtemp;
filename rtemp clear;

data _null_; if 0 then set r997o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R997 rows=' rows;
else do; set r997o; if not missing(actual) and abs(actual-(56))<=1e-10*max(1,abs(56)) then put 'ROUND2_PASS=R997';
else put 'ERROR: ROUND2_FAIL=R997 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r997:; quit;
