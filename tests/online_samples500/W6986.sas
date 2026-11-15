/* New workflow W6986; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6986i;
length gene $80;
gene='v01';x=0.0;y=2.2971413217793124;output;
gene='v02';x=0.3333333333333333;y=0.34160401733073426;output;
gene='v03';x=0.6666666666666666;y=2.910396399825625;output;
gene='v04';x=1.0;y=0.6409754055942217;output;
gene='v05';x=1.3333333333333333;y=3.4061809780178365;output;
gene='v06';x=1.6666666666666667;y=-0.812474239248169;output;
gene='v07';x=2.0;y=1.9420882693858157;output;
gene='v08';x=2.3333333333333335;y=3.200919490782686;output;
gene='v09';x=2.6666666666666665;y=0.9943451127957654;output;
gene='v10';x=3.0;y=4.365697756523887;output;
gene='v11';x=3.3333333333333335;y=4.194037363944397;output;
gene='v12';x=3.6666666666666665;y=3.717912800526743;output;
gene='v13';x=4.0;y=1.9439959558987099;output;
gene='v14';x=4.333333333333333;y=1.2727178091277165;output;
gene='v15';x=4.666666666666667;y=3.084746407232453;output;
run;
ods listing gpath="%sysfunc(pathname(work))";ods graphics /reset=index imagename="W6986" outputfmt=svg width=580px height=350px;title "W6986: synthetic SAS regression fixture";proc sgplot data=w6986i;scatter x=x y=y/markerattrs=(size=5);run;title;ods listing close;
data w6986m(keep=metric value);set w6986i;length metric $120;array measured[*] x y;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6986m;set w6986m;format value best32.;run;
proc export data=w6986m outfile="%sysfunc(pathname(work))/W6986.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6986;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6986:;quit;
