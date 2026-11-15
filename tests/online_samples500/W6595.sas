/* New workflow W6595; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6595i;
length grp $80;
grp='g1';eff=0.005747963182679561;veff=0.04229598747527111;output;
grp='g2';eff=-0.19728766404274523;veff=0.11378112597583437;output;
grp='g3';eff=0.19199522816424397;veff=0.27058415530799923;output;
grp='g1';eff=-0.7360618806487013;veff=0.23824479951254918;output;
grp='g2';eff=0.32940748659634633;veff=0.25625326104526025;output;
grp='g3';eff=-0.035872694602478106;veff=0.07670710224248337;output;
grp='g1';eff=0.6504523774795126;veff=0.1812320150679489;output;
grp='g2';eff=0.43825840874416633;veff=0.32803881299359633;output;
run;
%let varlist=grp;
%n26_wavgeff(w6595i,w6595o,0.99);run;
data w6595m(keep=metric value);set w6595o;length metric $120;array measured[*] estimate variance lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6595m;set w6595m;format value best32.;run;
proc export data=w6595m outfile="%sysfunc(pathname(work))/W6595.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6595;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6595:;quit;
