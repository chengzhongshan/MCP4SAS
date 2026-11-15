/* New workflow W6588; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6588i;
length grp $80;
grp='g1';eff=-0.18154558710970836;veff=0.32104061279322954;output;
grp='g2';eff=0.17297378696311838;veff=0.2073690468695132;output;
grp='g3';eff=-0.1086027038001327;veff=0.358781725416219;output;
grp='g1';eff=-0.3566365193712435;veff=0.26520049014715574;output;
grp='g2';eff=0.3616630006197883;veff=0.37055235715102713;output;
grp='g3';eff=0.3276319458857979;veff=0.33944315382007717;output;
grp='g1';eff=-0.4237509896700537;veff=0.13734754237297878;output;
grp='g2';eff=-0.6662891955924091;veff=0.1673574574371658;output;
run;
%let varlist=grp;
%n26_wavgeff(w6588i,w6588o,0.8);run;
data w6588m(keep=metric value);set w6588o;length metric $120;array measured[*] estimate variance lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6588m;set w6588m;format value best32.;run;
proc export data=w6588m outfile="%sysfunc(pathname(work))/W6588.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6588;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6588:;quit;
