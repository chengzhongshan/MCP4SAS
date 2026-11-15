/* New workflow V6274; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6274i;
length gene $80;
gene='allele01';ref=6;alt=5;output;
gene='allele02';ref=29;alt=16;output;
gene='allele03';ref=3;alt=38;output;
run;
%n26_calculate_binomial_P(dsdin=v6274i,dsdout=v6274o,Allele1_var=ref,Allele2_var=alt,TotReadCutoff=7);
data v6274m(keep=metric value);set v6274o;length metric $120;array measured[*] tot_reads binomial_P logP Ref_Frq A1A2log2Ratio;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6274m;set v6274m;format value best32.;run;
proc export data=v6274m outfile="%sysfunc(pathname(work))/V6274.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6274;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6274:;quit;
