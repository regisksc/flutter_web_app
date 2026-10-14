# docs: rules

- PRINCIPLES.md, INTERVIEW_PLAYBOOK.md, KNOWLEDGE.md, OPTIONAL.md, NEW_FEATURE.md: edit only with a reason.
- specs/: one file per feature from specs/_template.md. Name module changes, interfaces, acceptance criteria.
- adr/: numbered 0001-slug.md. Use adr/_template.md. Write only when a decision is hard to reverse.
- work/TRACE.md: append-only narration log. Use INTENT / LOOKING / DECISION / EVIDENCE / RISK.
- templates/: scaffold copies for tool/new_feature.sh. Not indexed. Do not edit placeholders.
- dsh-hook-row.yml and FIX_LOOP.md are owned by the infra work. Do not edit them here.
