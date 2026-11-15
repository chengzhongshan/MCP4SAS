/* New workflow W6685; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6685i;
n11=17;n12=43;n21=16;n22=52;output;
n11=34;n12=66;n21=9;n22=53;output;
n11=16;n12=66;n21=8;n22=70;output;
n11=9;n12=33;n21=30;n22=34;output;
n11=28;n12=29;n21=22;n22=52;output;
n11=22;n12=66;n21=13;n22=44;output;
n11=16;n12=41;n21=27;n22=66;output;
n11=14;n12=59;n21=6;n22=79;output;
run;
%n26_mhodds(w6685i,w6685o,0.9);run;
data w6685m(keep=metric value);set w6685o;length metric $120;array measured[*] estimate;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6685m;set w6685m;format value best32.;run;
proc export data=w6685m outfile="%sysfunc(pathname(work))/W6685.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6685;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6685:;quit;
