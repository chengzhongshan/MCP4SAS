/* New workflow W6998; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6998i;
length gene $80;
gene='v01';x=0.0;y=2.2623869977877415;output;
gene='v02';x=0.3333333333333333;y=-0.22803730843416598;output;
gene='v03';x=0.6666666666666666;y=3.332237474190293;output;
gene='v04';x=1.0;y=1.4904936562330566;output;
gene='v05';x=1.3333333333333333;y=-0.10946794468242516;output;
gene='v06';x=1.6666666666666667;y=4.598596925473004;output;
gene='v07';x=2.0;y=0.002303757833427955;output;
gene='v08';x=2.3333333333333335;y=0.933279812897394;output;
gene='v09';x=2.6666666666666665;y=0.5579893369304105;output;
gene='v10';x=3.0;y=2.4882326817932503;output;
gene='v11';x=3.3333333333333335;y=3.254722143135524;output;
gene='v12';x=3.6666666666666665;y=1.1666738187598518;output;
gene='v13';x=4.0;y=1.7274438259434326;output;
run;
ods listing gpath="%sysfunc(pathname(work))";ods graphics /reset=index imagename="W6998" outputfmt=svg width=580px height=350px;title "W6998: synthetic SAS regression fixture";proc sgplot data=w6998i;scatter x=x y=y/markerattrs=(size=7);run;title;ods listing close;
data w6998m(keep=metric value);set w6998i;length metric $120;array measured[*] x y;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6998m;set w6998m;format value best32.;run;
proc export data=w6998m outfile="%sysfunc(pathname(work))/W6998.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6998;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6998:;quit;
