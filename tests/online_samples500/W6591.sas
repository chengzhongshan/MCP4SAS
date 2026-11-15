/* New workflow W6591; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6591i;
length grp $80;
grp='g1';eff=-0.2324169283820684;veff=0.3648937105686876;output;
grp='g2';eff=-0.4263214083157827;veff=0.18354623643113785;output;
grp='g3';eff=-0.03455421338467235;veff=0.07139108850013377;output;
grp='g1';eff=-0.3773394790850797;veff=0.2796327923056747;output;
grp='g2';eff=-0.18248339815782755;veff=0.31334123896659455;output;
grp='g3';eff=0.17875367211471727;veff=0.29234253813882294;output;
grp='g1';eff=0.34571051296490896;veff=0.26551645024157233;output;
grp='g2';eff=0.30640374044424545;veff=0.20642866642933838;output;
grp='g3';eff=-0.7921069257435613;veff=0.14009068646531403;output;
grp='g1';eff=-0.35031780656719447;veff=0.22237728849641814;output;
grp='g2';eff=0.2327960711049082;veff=0.18797182761121167;output;
run;
%let varlist=grp;
%n26_wavgeff(w6591i,w6591o,0.99);run;
data w6591m(keep=metric value);set w6591o;length metric $120;array measured[*] estimate variance lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6591m;set w6591m;format value best32.;run;
proc export data=w6591m outfile="%sysfunc(pathname(work))/W6591.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6591;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6591:;quit;
