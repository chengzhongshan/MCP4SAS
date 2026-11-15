/* New workflow W6598; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6598i;
length grp $80;
grp='g1';eff=0.41017837205189944;veff=0.3984938425991549;output;
grp='g2';eff=0.8153083923059485;veff=0.3152950137986875;output;
grp='g3';eff=-0.1964379676964153;veff=0.14185908810289763;output;
grp='g1';eff=-0.6766572804878297;veff=0.24889841684807357;output;
grp='g2';eff=0.05197126120210305;veff=0.11726035973133792;output;
grp='g3';eff=0.7975097112032039;veff=0.05674411447322891;output;
grp='g1';eff=-0.5225993705787003;veff=0.3864970895124932;output;
grp='g2';eff=0.8272356808571759;veff=0.15358909298985918;output;
grp='g3';eff=-0.7493332751976824;veff=0.3875776392738329;output;
grp='g1';eff=-0.09028657199287438;veff=0.3667189927747958;output;
grp='g2';eff=-0.36226627591953253;veff=0.311268798722887;output;
run;
%let varlist=grp;
%n26_wavgeff(w6598i,w6598o,0.95);run;
data w6598m(keep=metric value);set w6598o;length metric $120;array measured[*] estimate variance lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6598m;set w6598m;format value best32.;run;
proc export data=w6598m outfile="%sysfunc(pathname(work))/W6598.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6598;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6598:;quit;
