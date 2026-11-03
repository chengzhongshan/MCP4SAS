/* R995 fileref_include, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_after_modification.sas:2 */

filename rtemp temp;
data _null_; file rtemp; put 'data r995o; actual=6*7; run;'; run;
%include rtemp;
filename rtemp clear;

data _null_; if 0 then set r995o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R995 rows=' rows;
else do; set r995o; if not missing(actual) and abs(actual-(42))<=1e-10*max(1,abs(42)) then put 'ROUND2_PASS=R995';
else put 'ERROR: ROUND2_FAIL=R995 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r995:; quit;
