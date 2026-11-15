/* New workflow W6985; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6985i;
length gene $80;
gene='v01';x=0.0;y=3.418346816365162;output;
gene='v02';x=0.3333333333333333;y=-0.9420573819422391;output;
gene='v03';x=0.6666666666666666;y=1.8156698291532125;output;
gene='v04';x=1.0;y=3.2142455323705996;output;
gene='v05';x=1.3333333333333333;y=3.967266646160714;output;
gene='v06';x=1.6666666666666667;y=0.9651805302091065;output;
gene='v07';x=2.0;y=-0.015083370185377198;output;
gene='v08';x=2.3333333333333335;y=1.7770355036208705;output;
gene='v09';x=2.6666666666666665;y=4.80530149994024;output;
gene='v10';x=3.0;y=2.794368499918627;output;
gene='v11';x=3.3333333333333335;y=3.971956792239884;output;
gene='v12';x=3.6666666666666665;y=2.0271341627710093;output;
gene='v13';x=4.0;y=5.84601955785803;output;
gene='v14';x=4.333333333333333;y=3.0533156515765345;output;
run;
ods listing gpath="%sysfunc(pathname(work))";ods graphics /reset=index imagename="W6985" outputfmt=svg width=540px height=410px;title "W6985: synthetic SAS regression fixture";proc sgplot data=w6985i;scatter x=x y=y/markerattrs=(size=4);run;title;ods listing close;
data w6985m(keep=metric value);set w6985i;length metric $120;array measured[*] x y;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6985m;set w6985m;format value best32.;run;
proc export data=w6985m outfile="%sysfunc(pathname(work))/W6985.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6985;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6985:;quit;
