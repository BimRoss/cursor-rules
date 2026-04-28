# Cursor Rules Release Checklist

Use this when you want `cursor-rules` updates to propagate into Slack employee personalities in production.

## Preconditions

- You are on a clean branch in `cursor-rules`.
- Rule edits and regenerated personality bundles are committed together.

## 1) Validate bundle sync locally

```bash
cd /Users/grant/Documents/cursor-rules
./scripts/sync-employee-personality.sh --all
./scripts/check-employee-personality.sh
git status --short
```

Expected: only intended files changed, and no sync-check errors.

## 2) Commit and tag a release

```bash
cd /Users/grant/Documents/cursor-rules
git add .cursor/rules docs .cursor/personas
git commit -m "release(cursor-rules): update personalities and docs"
git tag vX.Y.Z
git push origin HEAD
git push origin vX.Y.Z
```

Tag push triggers `.github/workflows/cursor-rules-images.yml`:
- builds/pushes `geeemoney/cursor-rules:X.Y.Z`
- updates `bimross/rancher-admin` `admin/apps/employee-factory/*-deployment.yaml` initContainer tags

## 3) Verify CI + GitOps update

```bash
cd /Users/grant/Documents/cursor-rules
gh run list --workflow "Build cursor-rules bundle image" --limit 5
gh run watch
```

Then confirm the manifest bump landed in `rancher-admin`:

```bash
cd /Users/grant/Documents/rancher-admin
git pull --rebase
rg "geeemoney/cursor-rules:X.Y.Z" admin/apps/employee-factory/*-deployment.yaml
```

## 4) Verify rollout in cluster

```bash
kubectl -n employee-factory rollout status deploy/employee-factory-alex
kubectl -n employee-factory rollout status deploy/employee-factory-tim
kubectl -n employee-factory rollout status deploy/employee-factory-ross
kubectl -n employee-factory rollout status deploy/employee-factory-garth
kubectl -n employee-factory rollout status deploy/employee-factory-joanne
```

Confirm running pods use the expected `cursor-rules` init image:

```bash
for d in alex tim ross garth joanne; do
  echo "== $d ==";
  kubectl -n employee-factory get deploy "employee-factory-$d" -o jsonpath='{.spec.template.spec.initContainers[?(@.name=="cursor-rules-bundle")].image}';
  echo;
done
```

Expected: all return `geeemoney/cursor-rules:X.Y.Z`.

## 5) If personalities still look stale

Check this chain in order:
1. `*.mdc` changed
2. `sync-employee-personality.sh --all` run
3. regenerated `.cursor/personas/*-personality.md` committed
4. `vX.Y.Z` tag pushed
5. `cursor-rules` workflow succeeded
6. `rancher-admin` manifest bump merged to `master`
7. Fleet applied and deployments rolled
