#!/usr/bin/env python3
"""Audit RHCSA task wording for concise, unambiguous exam-style phrasing."""
from __future__ import annotations

import argparse
import json
import re
import shlex
from pathlib import Path

QUOTED = re.compile(r'(?m)^([A-Z0-9_]+)="((?:\\.|[^"\\])*)"$')
PLAIN = re.compile(r'(?m)^([A-Z0-9_]+)=([^\n#]+)$')
BANNED_QUESTION = (
    re.compile(r'\bthe task is complete\b', re.I),
    re.compile(r'\boverwrite the destination if\b', re.I),
    re.compile(r'\bverify that the account records\b', re.I),
    re.compile(r'\bthe file must contain the requested command output\b', re.I),
)
BANNED_HINT = (
    re.compile(r'^Suggested command:', re.I),
    re.compile(r'^Suggested command sequence:', re.I),
    re.compile(r'run the command exactly as shown', re.I),
)

def decode(value: str) -> str:
    return (value.replace(r'\"', '"').replace(r'\$', '$')
            .replace(r'\`', '`').replace(r'\\', '\\'))

def parse(path: Path) -> dict[str, str]:
    text = path.read_text(encoding='utf-8', errors='replace')
    values = {m.group(1): decode(m.group(2)) for m in QUOTED.finditer(text)}
    for m in PLAIN.finditer(text):
        values.setdefault(m.group(1), m.group(2).strip())
    return values

def commands(values: dict[str, str], task: int) -> list[str]:
    items=[]
    prefix=f'TASK_{task}_COMMAND_'
    for key,value in values.items():
        if key.startswith(prefix):
            try: number=int(key.rsplit('_',1)[-1])
            except ValueError: number=999
            items.append((number,value))
    return [v for _,v in sorted(items)]

def normalize_command(value: str) -> str:
    return re.sub(r'\s+', ' ', value.strip().rstrip(';'))

def redirect_targets(command: str) -> list[str]:
    return re.findall(r'(?:^|\s)(?:2>|>>|>)\s*(/[^\s;&|]+)', command)

def audit_lab(path: Path) -> tuple[list[str], int]:
    values=parse(path)
    errors=[]
    try: task_count=int(values.get('LAB_TASK_COUNT','0'))
    except ValueError: task_count=0
    core = path.parent.name.isdigit() and int(path.parent.name) <= 10
    for field in ('OBJECTIVE_IDS','LAB_KIND','STATE_CHANGING','PERSISTENCE_REQUIRED'):
        if core and not values.get(field):
            errors.append(f'{path}: missing {field}')
    difficulty=values.get('DIFFICULTY','')
    if difficulty not in {'1','2','3','4','5'}:
        errors.append(f'{path}: invalid DIFFICULTY {difficulty!r}')
    for task in range(1,task_count+1):
        label=f'{path}: task {task}'
        question=values.get(f'TASK_{task}_QUESTION','').strip()
        hint=values.get(f'TASK_{task}_HINT','').strip()
        task_commands=commands(values,task)
        if not 20 <= len(question) <= 260:
            errors.append(f'{label}: question length {len(question)} outside 20..260')
        if not 18 <= len(hint) <= 240:
            errors.append(f'{label}: hint length {len(hint)} outside 18..240')
        for pattern in BANNED_QUESTION:
            if pattern.search(question):
                errors.append(f'{label}: overexplained question wording: {pattern.pattern}')
        for pattern in BANNED_HINT:
            if pattern.search(hint):
                errors.append(f'{label}: answer-revealing hint wording: {pattern.pattern}')
        if not task_commands:
            errors.append(f'{label}: no reference command')
        for command in task_commands:
            normalized=normalize_command(command)
            if len(normalized) >= 12 and normalized.lower() in normalize_command(hint).lower():
                errors.append(f'{label}: hint contains the full reference command')
            # Only output-capture questions must name their destination. Redirections
            # used internally to build a requested configuration are implementation
            # details and should not be leaked into an exam-style question.
            if re.search(r'\b(write|save|capture|redirect|append)\b', question, re.I):
                targets=[t.rstrip('\"\'').replace('\\n','') for t in redirect_targets(command) if t != '/dev/null']
                # Multi-step reference commands may contain implementation-only
                # redirects. The question must name at least one requested output
                # destination, not every internal temporary artifact.
                if targets and not any(target in question for target in targets):
                    errors.append(f'{label}: no requested output target is named in question')
        if re.search(r'\b(configure|change|modify|create|remove|enable|disable)\s+(it|this|that)\b', question, re.I):
            errors.append(f'{label}: ambiguous pronoun remains in question')
    return errors,task_count

def iter_labs(root: Path):
    yield from sorted(root.glob('[0-9]*/lab_*.sh'), key=lambda p:(int(p.parent.name),p.name))

def main() -> int:
    parser=argparse.ArgumentParser()
    parser.add_argument('questions_dir',type=Path)
    parser.add_argument('--json',action='store_true')
    parser.add_argument('--apply',action='store_true',help='Retained for compatibility; v7 wording is generated at release build time.')
    args=parser.parse_args()
    labs=list(iter_labs(args.questions_dir.resolve()))
    errors=[]; tasks=0
    for lab in labs:
        e,n=audit_lab(lab); errors.extend(e); tasks+=n
    questions=[]; hints=[]
    for lab in labs:
        values=parse(lab)
        for n in range(1,int(values.get('LAB_TASK_COUNT','0'))+1):
            questions.append(len(values.get(f'TASK_{n}_QUESTION','')))
            hints.append(len(values.get(f'TASK_{n}_HINT','')))
    report={
        'labs':len(labs),'tasks':tasks,'errors':errors,'changed_metadata_lines':0,
        'question_length':{'min':min(questions,default=0),'max':max(questions,default=0),'average':round(sum(questions)/len(questions),1) if questions else 0},
        'hint_length':{'min':min(hints,default=0),'max':max(hints,default=0),'average':round(sum(hints)/len(hints),1) if hints else 0},
        'standard':'Concise end-state questions; progressive hints without complete commands',
    }
    if args.json: print(json.dumps(report,indent=2,sort_keys=True))
    else:
        print(f"Labs audited: {report['labs']}")
        print(f"Tasks audited: {report['tasks']}")
        print('Question quality: '+('PASS' if not errors else f'FAIL ({len(errors)})'))
        for error in errors[:100]: print(f'- {error}')
    return 1 if errors else 0
if __name__=='__main__': raise SystemExit(main())
