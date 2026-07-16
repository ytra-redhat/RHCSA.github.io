#!/usr/bin/env python3
"""Validate and report RHCSA EX200 RHEL 10 objective coverage."""
from __future__ import annotations
import argparse,json,re
from collections import defaultdict,Counter
from pathlib import Path

ASSIGN=re.compile(r'(?m)^([A-Z0-9_]+)="((?:\\.|[^"\\])*)"$')
PLAIN=re.compile(r'(?m)^([A-Z0-9_]+)=([^\n#]+)$')
def decode(v): return v.replace(r'\"','"').replace(r'\$','$').replace(r'\`','`').replace(r'\\','\\')
def parse(path):
 text=path.read_text(encoding='utf-8',errors='replace')
 d={m.group(1):decode(m.group(2)) for m in ASSIGN.finditer(text)}
 for m in PLAIN.finditer(text): d.setdefault(m.group(1),m.group(2).strip())
 return d

def main():
 ap=argparse.ArgumentParser(); ap.add_argument('simulator_dir',type=Path); ap.add_argument('--json',action='store_true'); ap.add_argument('--output',type=Path)
 args=ap.parse_args(); sim=args.simulator_dir.resolve(); manifest=json.loads((sim/'config/rhcsa_v10_objectives.json').read_text())
 official={o['id']:o for o in manifest['objectives']}; rows=defaultdict(list); errors=[]
 bonus_labs=0; total_labs=0; total_tasks=0
 for path in sorted((sim/'questions').glob('[0-9]*/lab_*.sh'),key=lambda p:(int(p.parent.name),p.name)):
  total_labs+=1; v=parse(path); total_tasks+=int(v.get('LAB_TASK_COUNT','0') or 0)
  ch=int(path.parent.name)
  if ch>10: bonus_labs+=1; continue
  ids=[x.strip() for x in v.get('OBJECTIVE_IDS','').split(',') if x.strip()]
  if not ids: errors.append(f'{path.relative_to(sim)}: no OBJECTIVE_IDS'); continue
  for oid in ids:
   if oid not in official:
    errors.append(f'{path.relative_to(sim)}: unknown objective {oid}'); continue
   if official[oid]['chapter'] != ch:
    errors.append(f'{path.relative_to(sim)}: objective {oid} belongs to chapter {official[oid]["chapter"]}')
   rows[oid].append({
    'path':str(path.relative_to(sim)), 'difficulty':int(v.get('DIFFICULTY','0') or 0),
    'kind':v.get('LAB_KIND',''), 'state_changing':v.get('STATE_CHANGING','').lower()=='true',
    'persistence':v.get('PERSISTENCE_REQUIRED','false'),
    'tasks':int(v.get('LAB_TASK_COUNT','0') or 0),
   })
 objective_rows=[]
 for oid,obj in official.items():
  labs=rows.get(oid,[]); levels=sorted({x['difficulty'] for x in labs}); kinds=Counter(x['kind'] for x in labs)
  exam=sum(x['kind'] in {'exam','integrated-exam','guided-manual'} for x in labs)
  state=sum(x['state_changing'] for x in labs)
  persistence=sum(x['persistence'] not in {'','false'} for x in labs)
  status='pass'; issues=[]
  if len(labs)<obj['minimum_labs']: issues.append(f'labs {len(labs)} < {obj["minimum_labs"]}')
  if len(levels)<obj['minimum_difficulty_levels']: issues.append(f'difficulty levels {levels}')
  if exam<obj['minimum_exam_labs']: issues.append('no exam-grade lab')
  if state<obj['minimum_state_changing_labs']: issues.append('no state-changing lab')
  if obj.get('persistence_expected') and persistence<1: issues.append('no persistence-focused lab')
  if issues: status='fail'; errors.append(f'{oid}: '+', '.join(issues))
  objective_rows.append({
   'id':oid,'chapter':obj['chapter'],'title':obj['title'],'status':status,'lab_count':len(labs),
   'task_count':sum(x['tasks'] for x in labs),'difficulty_levels':levels,'difficulty_counts':dict(sorted(Counter(str(x['difficulty']) for x in labs).items())),
   'exam_lab_count':exam,'state_changing_lab_count':state,'persistence_lab_count':persistence,'kind_counts':dict(kinds),
   'source_refs':obj.get('source_refs',{}),'issues':issues,'labs':labs,
  })
 report={
  'exam':manifest['exam'],'platform':manifest['platform'],'official_objectives':len(official),
  'objectives_passed':sum(x['status']=='pass' for x in objective_rows),'objectives_failed':sum(x['status']!='pass' for x in objective_rows),
  'core_labs':total_labs-bonus_labs,'supplementary_labs':bonus_labs,'total_labs':total_labs,'total_tasks':total_tasks,
  'policy':manifest['coverage_policy'],'objectives':objective_rows,'errors':errors,
 }
 payload=json.dumps(report,indent=2,sort_keys=True)+'\n'
 if args.output: args.output.write_text(payload)
 if args.json or not args.output: print(payload,end='')
 return 1 if errors else 0
if __name__=='__main__': raise SystemExit(main())
