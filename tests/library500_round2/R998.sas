/* R998 fileref_include, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_after_modification.sas:2 */

filename rtemp temp;
data _null_; file rtemp; put 'data r998o; actual=9*7; run;'; run;
%include rtemp;
filename rtemp clear;

data _null_; if 0 then set r998o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R998 rows=' rows;
else do; set r998o; if not missing(actual) and abs(actual-(63))<=1e-10*max(1,abs(63)) then put 'ROUND2_PASS=R998';
else put 'ERROR: ROUND2_FAIL=R998 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r998:; quit;
