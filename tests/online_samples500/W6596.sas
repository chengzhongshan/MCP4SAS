/* New workflow W6596; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6596i;
length grp $80;
grp='g1';eff=-0.3012595509003608;veff=0.20879248938103798;output;
grp='g2';eff=-0.35044898840409755;veff=0.05821547153256615;output;
grp='g3';eff=-0.22673380724113723;veff=0.18620945286805596;output;
grp='g1';eff=0.6010672882252981;veff=0.17593277725598613;output;
grp='g2';eff=-0.30872937312125454;veff=0.38396471484912775;output;
grp='g3';eff=-0.5793202131321928;veff=0.3941063021244256;output;
grp='g1';eff=-0.03654866866757478;veff=0.3909747540149215;output;
grp='g2';eff=-0.24896306725082284;veff=0.1724670732122508;output;
grp='g3';eff=0.12505646865377107;veff=0.3606213029226135;output;
run;
%let varlist=grp;
%n26_wavgeff(w6596i,w6596o,0.8);run;
data w6596m(keep=metric value);set w6596o;length metric $120;array measured[*] estimate variance lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6596m;set w6596m;format value best32.;run;
proc export data=w6596m outfile="%sysfunc(pathname(work))/W6596.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6596;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6596:;quit;
