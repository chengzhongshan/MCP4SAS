/* New workflow W6589; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6589i;
length grp $80;
grp='g1';eff=0.7048684904756894;veff=0.1396904972344459;output;
grp='g2';eff=0.26840255034876814;veff=0.11639146919952471;output;
grp='g3';eff=-0.5089868556741453;veff=0.09184818908919536;output;
grp='g1';eff=-0.17064796868645693;veff=0.06555308045836344;output;
grp='g2';eff=-0.0017866879677124192;veff=0.3307267486798362;output;
grp='g3';eff=0.837617836431563;veff=0.1812181604279047;output;
grp='g1';eff=0.0808069315104103;veff=0.1541436674808115;output;
grp='g2';eff=0.6040615815113644;veff=0.3641268226301566;output;
grp='g3';eff=-0.21070255461180842;veff=0.2839327406121026;output;
run;
%let varlist=grp;
%n26_wavgeff(w6589i,w6589o,0.9);run;
data w6589m(keep=metric value);set w6589o;length metric $120;array measured[*] estimate variance lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6589m;set w6589m;format value best32.;run;
proc export data=w6589m outfile="%sysfunc(pathname(work))/W6589.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6589;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6589:;quit;
