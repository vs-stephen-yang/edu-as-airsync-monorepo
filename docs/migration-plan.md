# Push Migration Artifacts to Monorepo

## Context
The monorepo migration is complete at `/tmp/tmp.axxPus6Pe3/monorepo` and already pushed to `vs-stephen-yang/edu-as-airsync-monorepo` on `main`. Now we need to add the migration plan doc and migration script to the repo on a new branch.

## Steps

1. `cd /tmp/tmp.axxPus6Pe3/monorepo`
2. Create branch: `git checkout -b chore/add-migration-docs`
3. Copy files into the repo:
   - `scripts/migrate.sh` — already exists in the monorepo from the migration (it was in the working dir, not committed). Copy from `C:\Users\stephen\c\monorepo\scripts\migrate.sh`
   - `docs/migration-plan.md` — copy from `C:\Users\stephen\.claude\plans\glowing-sleeping-comet.md` (rename for clarity)
4. `git add scripts/migrate.sh docs/migration-plan.md`
5. `git commit -m "docs: add migration plan and migration script"`
6. `git push -u origin chore/add-migration-docs`

## Files
- Source: `C:\Users\stephen\c\monorepo\scripts\migrate.sh`
- Source: This plan file (will be copied as `docs/migration-plan.md`)
- Target repo: `/tmp/tmp.axxPus6Pe3/monorepo`
