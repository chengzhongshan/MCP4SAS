/* New workflow W6544; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6544i;
n11=32;n12=66;n21=27;n22=92;output;
n11=30;n12=24;n21=28;n22=43;output;
n11=32;n12=28;n21=25;n22=85;output;
n11=37;n12=47;n21=7;n22=66;output;
n11=45;n12=40;n21=29;n22=94;output;
n11=43;n12=66;n21=13;n22=36;output;
n11=19;n12=57;n21=7;n22=71;output;
run;
%n26_compodds(w6544i,w6544o);run;
%n26_wavgodds(w6544o,w6544pool,1,0.95);run;
data w6544m(keep=metric value);set w6544pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6544m;set w6544m;format value best32.;run;
proc export data=w6544m outfile="%sysfunc(pathname(work))/W6544.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6544;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6544:;quit;
