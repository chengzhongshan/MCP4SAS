/* R994 fileref_include, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_after_modification.sas:2 */

filename rtemp temp;
data _null_; file rtemp; put 'data r994o; actual=5*7; run;'; run;
%include rtemp;
filename rtemp clear;

data _null_; if 0 then set r994o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R994 rows=' rows;
else do; set r994o; if not missing(actual) and abs(actual-(35))<=1e-10*max(1,abs(35)) then put 'ROUND2_PASS=R994';
else put 'ERROR: ROUND2_FAIL=R994 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r994:; quit;
