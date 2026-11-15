/* New workflow W6584; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6584i;
length grp $80;
grp='g1';eff=0.528083585184882;veff=0.27931990775140364;output;
grp='g2';eff=-0.6817202350857994;veff=0.07032022096058808;output;
grp='g3';eff=0.7685140832611514;veff=0.2809647725031811;output;
grp='g1';eff=0.4526484247800848;veff=0.08263817015580796;output;
grp='g2';eff=0.6503958193338946;veff=0.19695278032252797;output;
grp='g3';eff=-0.44180534774666086;veff=0.03765964259253887;output;
grp='g1';eff=0.661147747166396;veff=0.17759418484703207;output;
grp='g2';eff=-0.40661607515955167;veff=0.026567849718627006;output;
grp='g3';eff=0.04707771773051128;veff=0.19160077529330383;output;
grp='g1';eff=0.3667403689463846;veff=0.022996900169583542;output;
grp='g2';eff=-0.366385077320882;veff=0.13208434957574558;output;
run;
%let varlist=grp;
%n26_wavgeff(w6584i,w6584o,0.8);run;
data w6584m(keep=metric value);set w6584o;length metric $120;array measured[*] estimate variance lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6584m;set w6584m;format value best32.;run;
proc export data=w6584m outfile="%sysfunc(pathname(work))/W6584.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6584;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6584:;quit;
