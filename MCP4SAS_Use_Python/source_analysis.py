"""SAS lexical contexts, ported from SAS_Source_Analysis.pm.

Keep character positions/newlines unchanged in masked views. These checks are
advisory source analysis, not a replacement for SAS compilation.
"""
import re

BUILTINS = set(('let put do to by while until else end if then abort window display str nrstr bquote nrbquote superq sysfunc qsysfunc syscall sysexec sysget symexist symdel symglobl symlocal sysmacexist sysmacdelete scan qscan substr qsubstr upcase qupcase lowcase qlowcase length index eval sysevalf quote nrquote unquote cmpres left trim sysprod sysmacroname global local mend macro goto return include inc').split())
MACRO_QUOTE_HEADER = re.compile(r'%(str|nrstr|quote|nrquote|bquote|nrbquote|superq)\b\s*\(',re.I)
INLINE_HEADER = re.compile(r'(datalines4?|cards4?|parmcards4?)\s*;',re.I)

def is_builtin_macro_name(name):
    return not name or name.lower() in BUILTINS

def is_local_file_candidate(value):
    return bool(value) and len(value) <= 4096 and not re.search(r'[\r\n\x00]', value)

def include_target_needs_runtime_resolution(target):
    return bool(target and re.search(r'[&%]', target))

def blank(text):
    return re.sub(r'[^\r\n]', ' ', text)

def macro_quote_span(text, offset):
    match = MACRO_QUOTE_HEADER.match(text,offset)
    if not match:
        return None
    body = match.end()
    i, depth, children = body, 1, []
    while i < len(text):
        if text[i] == '%' and text[i+1:i+2] in ('(', ')', "'", '"'):
            i += 2
            continue
        child = macro_quote_span(text, i) if text[i] == '%' else None
        if child:
            children.append(child)
            i = child['end']
            continue
        if text[i] == '(':
            depth += 1
        elif text[i] == ')':
            depth -= 1
            if depth == 0:
                return dict(name=match[1].lower(), start=offset, body=body, end=i+1, closed=1, children=children)
        i += 1
    return dict(name=match[1].lower(), start=offset, body=body, end=len(text), closed=0, children=children)

def all_spans(span):
    return [span] + [child for item in span['children'] for child in all_spans(item)]

def inside_unquoted_prx(text, offset):
    matches = list(re.finditer(r'\bprx(match|change)\s*\(', text[:offset+1], re.I))
    if not matches:
        return False
    match = matches[-1]
    i = match.end()
    while i < len(text) and text[i].isspace():
        i += 1
    first = text[i:i+1]
    if first in ("'", '"'):
        return False
    change = match[1].lower() == 'change'
    if change:
        if first.lower() != 's':
            return False
        i += 1
    elif first.lower() == 'm':
        i += 1
    delimiter = text[i:i+1]
    if not delimiter or re.match(r'[A-Za-z0-9_\s]', delimiter):
        return False
    count, escaped = 0, False
    for pos in range(i+1, len(text)):
        char = text[pos]
        if escaped:
            escaped = False
        elif char == '\\':
            escaped = True
        elif char == delimiter:
            count += 1
            if count == (2 if change else 1):
                return offset <= pos
    return False

def analyze_inline_data(text):
    text = text or ''
    masked, unclosed = list(text), []
    i, quote, block, comment, statement_start = 0, '', False, False, True
    while i < len(text):
        ch, pair = text[i], text[i:i+2]
        if block:
            if pair == '*/':
                block = False
                i += 2
            else:
                i += 1
            continue
        if comment:
            if ch == ';':
                comment = False
            i += 1
            continue
        if quote:
            if ch == quote:
                if text[i+1:i+2] == quote:
                    i += 2
                    continue
                quote = ''
            i += 1
            continue
        if pair == '/*':
            block = True
            i += 2
            continue
        if pair == '%*' or (ch == '*' and statement_start):
            comment = True
            i += 2 if pair == '%*' else 1
            continue
        span = macro_quote_span(text, i) if ch == '%' else None
        if span:
            i, statement_start = span['end'], False
            continue
        if ch in ("'", '"'):
            quote, statement_start = ch, False
            i += 1
            continue
        if ch.isspace():
            i += 1
            continue
        if ch == ';':
            statement_start = True
            i += 1
            continue
        match = INLINE_HEADER.match(text,i) if statement_start else None
        if match:
            header_end = match.end()
            end = text.find('\n', header_end)
            end = len(text) if end < 0 else end
            if not text[header_end:end].strip():
                start = end+1 if end < len(text) else len(text)
                cursor, found = start, False
                terminator = r'^\s*;;;;' if match[1].endswith('4') else r'^\s*;'
                while cursor < len(text):
                    end = text.find('\n', cursor)
                    end = len(text) if end < 0 else end
                    if re.match(terminator, text[cursor:end]):
                        found = True
                        break
                    cursor = end+1 if end < len(text) else len(text)
                masked[start:cursor] = blank(text[start:cursor])
                if not found:
                    unclosed.append(dict(line=1+text[:i].count('\n'), keyword=match[1].upper()))
                i, statement_start = cursor, True
                continue
        statement_start = False
        i += 1
    return dict(masked=''.join(masked), unclosed=unclosed)

def analyze_source(text):
    text = text or ''
    inline = analyze_inline_data(text)
    scan = inline['masked']
    masked, comments = list(scan), list(scan)
    last_line = 1 + text.count('\n')
    findings = [dict(type='unclosed_inline_data', line=f['line'], message=f"Inline data declaration {f['keyword']} is missing its terminating line", context_ref=list(range(f['line']-1,last_line+1))) for f in inline['unclosed']]
    macro_quotes, single_quotes, double_quotes = [], [], []
    i, line, quote, block, comment, statement_start, start_line = 0, 1, '', False, False, True, 0
    quote_start, comment_start_state = 0, True
    def mask(offset, count, is_comment=False):
        replacement = blank(scan[offset:offset+count])
        masked[offset:offset+count] = replacement
        if is_comment:
            comments[offset:offset+count] = replacement
    while i < len(scan):
        ch, pair = scan[i], scan[i:i+2]
        if block:
            if pair == '*/':
                mask(i,2,True)
                block = False
                i += 2
            else:
                mask(i,1,True)
                line += ch == '\n'
                i += 1
            continue
        if comment:
            mask(i,1,True)
            if ch == ';':
                comment, statement_start = False, comment_start_state
            line += ch == '\n'
            i += 1
            continue
        if quote:
            if ch == quote and scan[i+1:i+2] == quote:
                mask(i,2)
                i += 2
                continue
            span = macro_quote_span(scan,i) if quote == '"' and ch == '%' else None
            if span:
                macro_quotes.extend(all_spans(span))
                line += scan[i:span['end']].count('\n')
                mask(i,span['end']-i)
                i = span['end']
                continue
            mask(i,1)
            if ch == quote:
                (single_quotes if quote == "'" else double_quotes).append(dict(start=quote_start,end=i+1))
                quote = ''
            line += ch == '\n'
            i += 1
            continue
        if pair == '/*':
            start_line, block = line, True
            mask(i,2,True)
            i += 2
            continue
        if pair == '*/':
            if not inside_unquoted_prx(scan,i+1):
                findings.append(dict(type='unexpected_comment_close',line=line,message="Unexpected closing block comment '*/'",context_ref=list(range(line-2,line+3))))
            i += 2
            statement_start = False
            continue
        if pair == '%*' or (ch == '*' and statement_start):
            comment_start_state, comment = statement_start, True
            count = 2 if pair == '%*' else 1
            mask(i,count,True)
            i += count
            continue
        span = macro_quote_span(scan,i) if ch == '%' else None
        if span:
            macro_quotes.extend(all_spans(span))
            if not span['closed']:
                findings.append(dict(type='unclosed_macro_invocation',line=line,message=f"Macro quoting function %{span['name']}( is missing its closing ')'",context_ref=list(range(line-2,last_line+1))))
            line += scan[i:span['end']].count('\n')
            mask(i,span['end']-i)
            i, statement_start = span['end'], False
            continue
        if ch in ("'", '"'):
            quote, quote_start, start_line, statement_start = ch, i, line, False
            mask(i,1)
            i += 1
            continue
        if ch == '\n':
            line += 1
        elif not ch.isspace():
            statement_start = ch == ';'
        i += 1
    if block or quote:
        kind = 'block_comment' if block else 'single_quote' if quote == "'" else 'double_quote'
        description = 'block comment' if block else 'single-quoted string' if quote == "'" else 'double-quoted string'
        findings.append(dict(type='unclosed_'+kind,line=start_line,message=f'Unclosed {description} starting on line {start_line}',context_ref=list(range(start_line-2,last_line+1))))
    return dict(masked=''.join(masked),comments_masked=''.join(comments),findings=findings,macro_quotes=macro_quotes,single_quotes=single_quotes,double_quotes=double_quotes)

def mask_noncode(text):
    return analyze_source(text)['masked']

def mask_comments(text):
    return analyze_source(text)['comments_masked']

def mask_inline_data(text):
    return analyze_inline_data(text)['masked']

def mask_macro_literals(text, analysis=None):
    analysis = analysis or analyze_source(text)
    masked = list(analysis['comments_masked'])
    for span in analysis['macro_quotes']:
        if span['name'] != 'nrstr':
            continue
        nested = any(s['name']=='nrstr' and s['start']<span['start'] and s['end']>=span['end'] for s in analysis['macro_quotes'])
        if not nested and any(re.search(r'%unquote\s*\(\s*$',analysis[key][:span['start']],re.I) for key in ('masked','comments_masked')):
            continue
        end = span['end'] - bool(span['closed'])
        masked[span['body']:end] = blank(''.join(masked[span['body']:end]))
    return ''.join(masked)

def literal_is_executable(analysis, span, macro_evaluation=False):
    key = int(macro_evaluation)
    cache = analysis.setdefault('literal_execution_contexts', {})
    if key not in cache:
        spans = sorted(analysis['single_quotes']+analysis['double_quotes'],key=lambda x:x['start'])
        calls = r'call\s+execute|dosubl|resolve' if key else r'call\s+execute|dosubl'
        stack, contexts, index, active = [], {}, 0, 0
        for match in re.finditer(r'\b('+calls+r')\s*\(|([()])',analysis['masked'],re.I):
            while index < len(spans) and spans[index]['start'] < match.end():
                contexts[spans[index]['start']] = active
                index += 1
            if match[1]:
                stack.append(1)
                active += 1
            elif match[2] == '(':
                stack.append(0)
            else:
                active -= stack.pop() if stack else 0
        for item in spans[index:]:
            contexts[item['start']] = active
        cache[key] = contexts
    return cache[key].get(span['start'],0)

def macro_dependency_view(text,analysis=None):
    text = text or ''
    analysis = analysis if analysis is not None else analyze_source(text)
    masked = list(mask_macro_literals(text,analysis))
    for span in analysis['single_quotes']:
        if literal_is_executable(analysis,span,True):
            body = text[span['start']+1:span['end']-1]
            positions, decoded, i = [], [], 0
            while i < len(body):
                size = 2 if body[i:i+2] == "''" else 1
                positions.append((i,size))
                decoded.append(body[i])
                i += size
            decoded = ''.join(decoded)
            view = macro_dependency_view(decoded)
            for index,(pos,size) in enumerate(positions):
                if view[index] != decoded[index]:
                    offset = span['start']+1+pos
                    masked[offset:offset+size] = blank(body[pos:pos+size])
        else:
            masked[span['start']:span['end']] = blank(''.join(masked[span['start']:span['end']]))
    return ''.join(masked)

def include_targets(text,analysis=None):
    text = text or ''
    analysis = analysis if analysis is not None else analyze_source(text)
    located, deferred = [], []
    for span in analysis['single_quotes']+analysis['double_quotes']:
        if literal_is_executable(analysis,span):
            deferred.append(span)
            quote = text[span['start']]
            body = text[span['start']+1:span['end']-1].replace(quote+quote,quote)
            located.extend((span['start'],len(located)+i,value) for i,value in enumerate(include_targets(body)))
    for match in re.finditer(r'%inc(?:lude)?\b',analysis['masked'],re.I):
        if any(s['start']<=match.start()<s['end'] for s in deferred):
            continue
        tail = analysis['comments_masked'][match.start():]
        header = re.match(r'%inc(?:lude)?\s+',tail,re.I)
        if not header:
            continue
        pos = header.end()
        while pos < len(tail):
            while pos < len(tail) and tail[pos].isspace():
                pos += 1
            quote = tail[pos:pos+1]
            if quote not in ("'",'"'):
                break
            pos += 1
            value, closed = '', False
            while pos < len(tail):
                char = tail[pos]
                pos += 1
                if char == quote:
                    if tail[pos:pos+1] == quote:
                        value += quote
                        pos += 1
                        continue
                    closed = True
                    break
                value += char
            if not closed:
                break
            if value:
                located.append((match.start(),len(located),value))
    return [item[2] for item in sorted(located,key=lambda x:x[:2])]

def open_code_macro_issues(text,masked=None):
    masked = masked if masked is not None else mask_noncode(text)
    findings, groups, depth, pending = [], [], 0, False
    def add(kind,line,message):
        findings.append(dict(type=kind,line=line,message=message,context_ref=list(range(line-2,line+3))))
    for match in re.finditer(r'%(macro|mend|local|goto|return|do|end|if|then|else|let|global)\b',masked,re.I):
        word, prefix, tail = match[1].lower(), masked[:match.start()], masked[match.end():]
        if re.match(r'\s*:',tail):
            continue
        line = 1 + prefix.count('\n')
        if word == 'macro':
            depth += 1
            continue
        if word == 'mend':
            if depth:
                depth -= 1
            else:
                add('open_code_mend',line,'Macro end statement %mend appears outside a %macro/%mend block')
            continue
        if depth:
            continue
        if word in ('local','goto','return'):
            add('open_code_macro_control',line,f'Macro control statement %{word} appears in open SAS code; place it inside a %macro/%mend definition')
        elif word == 'if':
            if groups:
                add('nested_open_code_if',line,'Nested %IF in open code is unsupported; put nested conditional logic inside a macro definition')
            if not re.match(r'[^;]*?%then\s+%do\s*;',tail,re.I):
                add('open_code_if_action',line,'Open-code %IF requires %THEN %DO; ... %END; (SAS 9.4M5 or later), or a macro wrapper')
            pending = True
        elif word == 'then':
            if not pending:
                add('open_code_then',line,'Orphan %THEN in open code has no preceding %IF')
            pending = False
        elif word == 'else':
            if not re.search(r'%end\s*;\s*$',prefix,re.I):
                add('open_code_else',line,'Orphan %ELSE in open code requires a preceding conditional %DO/%END group')
        elif word == 'do':
            if not (re.search(r'%(?:then|else)\s*$',prefix,re.I) and re.match(r'\s*;',tail)):
                add('open_code_do',line,'Indexed, %WHILE, %UNTIL and standalone %DO loops require a macro definition; open code permits conditional %THEN/%ELSE %DO groups')
            groups.append(line)
        elif word == 'end':
            if groups:
                groups.pop()
            else:
                add('open_code_end',line,'Orphan %END in open code has no matching %DO group')
        elif word in ('let','global') and re.search(r'%(?:put|let|global|local|if|do|macro)\b',tail.split(';',1)[0],re.I):
            add('macro_statement_recursion',line,f'Possible missing semicolon after %{word} before another macro statement; this can cause open-code statement recursion')
    if depth:
        add('unclosed_macro_definition',1+masked.count('\n'),'A %macro block appears to be missing its matching %mend')
    for line in groups:
        add('unclosed_open_code_do',line,'Open-code %DO group is missing a matching %END; finish the conditional before submission')
    return findings

def format_name_issues(text,masked=None):
    masked, result = masked if masked is not None else mask_noncode(text), []
    for proc in re.finditer(r'\bproc\s+format\b[^;]*;(.*?)\b(?:run|quit)\s*;',masked,re.I|re.S):
        for match in re.finditer(r'\b(value|invalue|picture)\s+\$?([A-Za-z_]\w*)\b',proc[1],re.I):
            kind,name = match[1].lower(),match[2]
            if name[-1].isdigit():
                line = 1 + masked[:proc.start(1)+match.start(2)].count('\n')
                result.append(dict(type='invalid_literal_format_name',line=line,message=f"Literal {kind} name '{name}' ends in a digit; SAS format/informat names must end in a nondigit. Use a letter suffix.",context_ref=[line]))
    return result

def fileref_name_issues(text,masked=None):
    masked, result = masked if masked is not None else mask_noncode(text), []
    for match in re.finditer(r'\bfilename\s+([A-Za-z_]\w*)\b',masked,re.I):
        if len(match[1])>8:
            line = 1+masked[:match.start(1)].count('\n')
            result.append(dict(type='invalid_literal_fileref_name',line=line,message=f"Literal fileref '{match[1]}' exceeds the SAS limit of 8 characters; choose a shorter fileref.",context_ref=[line]))
    return result
