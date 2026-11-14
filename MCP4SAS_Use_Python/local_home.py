"""Expand local HOME literals without rewriting comments or inline data."""
from .source_analysis import analyze_source

def expand_code_paths(code, home):
    if not home:
        return code
    analysis = analyze_source(code)
    for span in sorted(analysis['single_quotes']+analysis['double_quotes'],key=lambda x:x['start'],reverse=True):
        literal = code[span['start']:span['end']]
        quote,body = literal[0],literal[1:-1]
        if body == '~' or body.startswith(('~/','~\\')):
            prefix = home.replace(quote,quote+quote) if quote == "'" else '%superq(PIPELINE_SAS_HOME)'
            code = code[:span['start']]+quote+prefix+body[1:]+quote+code[span['end']:]
    return code
