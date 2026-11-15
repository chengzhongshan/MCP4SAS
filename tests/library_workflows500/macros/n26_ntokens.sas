/* Test-only namespaced definition from ntokens.sas; original SHA256 057065223ffaa686f74e9618088ea9fb59798b42cc2a9089f42c1ff905f7fb81. */
%macro n26_ntokens(list);
    %eval(1 + %length(%sysfunc(compbl(&list))) - %length(%sysfunc(compress(&list))))
%mend n26_ntokens;
