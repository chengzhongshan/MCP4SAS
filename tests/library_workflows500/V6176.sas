/* New workflow V6176; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6176i;
length gene $80;
gene='gene01';raw_c1=68.13;raw_c2=-21.8;raw_c3=14.270000000000001;output;
gene='gene02';raw_c1=-6.74;raw_c2=8.33;raw_c3=-19.599999999999998;output;
gene='gene03';raw_c1=49.39;raw_c2=54.46;raw_c3=-21.47;output;
gene='gene04';raw_c1=-2.48;raw_c2=13.59;raw_c3=34.660000000000004;output;
gene='gene05';raw_c1=-16.35;raw_c2=-18.28;raw_c3=13.790000000000001;output;
run;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.v6176i,Rgx=raw_);
data v6176m(keep=metric value);set v6176i;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6176i out=v6176s(keep=name type) noprint;run;data v6176s(keep=metric value);set v6176s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6176m data=v6176s;run;

data v6176m;set v6176m;format value best32.;run;
proc export data=v6176m outfile="%sysfunc(pathname(work))/V6176.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6176;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6176:;quit;
