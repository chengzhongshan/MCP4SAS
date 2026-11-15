/* New workflow W6586; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6586i;
length grp $80;
grp='g1';eff=0.37314574134288536;veff=0.13064606894351607;output;
grp='g2';eff=0.6926183180572174;veff=0.3613837719467148;output;
grp='g3';eff=-0.6405915279727709;veff=0.1066169051997917;output;
grp='g1';eff=-0.37542803972272804;veff=0.13068345831018857;output;
grp='g2';eff=-0.48957949033177345;veff=0.26399703173463285;output;
grp='g3';eff=-0.041106486166451184;veff=0.21496797058394276;output;
grp='g1';eff=0.028352533659248946;veff=0.3300524032970765;output;
grp='g2';eff=-0.04335030132533946;veff=0.28110895480013215;output;
grp='g3';eff=-0.027504381951933388;veff=0.17043844472688782;output;
grp='g1';eff=-0.15440967040780207;veff=0.33069505331616655;output;
grp='g2';eff=-0.7629264847144254;veff=0.20721518323429816;output;
grp='g3';eff=-0.2189402534029009;veff=0.3974367293863735;output;
grp='g1';eff=-0.03192073665446982;veff=0.3573220342962657;output;
run;
%let varlist=grp;
%n26_wavgeff(w6586i,w6586o,0.95);run;
data w6586m(keep=metric value);set w6586o;length metric $120;array measured[*] estimate variance lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6586m;set w6586m;format value best32.;run;
proc export data=w6586m outfile="%sysfunc(pathname(work))/W6586.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6586;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6586:;quit;
