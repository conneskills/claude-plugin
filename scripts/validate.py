#!/usr/bin/env python3
"""Comprobaciones de publicación del plugin.

Existe por un fallo concreto: una descripción de skill con `: ` dentro rompe el
escalar YAML del frontmatter, y eso se publica sin que nada avise — el manifiesto
sigue siendo JSON válido y el repo no tiene forma de notarlo. Lo que se valida
aquí es exactamente lo que no se ve al revisar el diff.

Uso: python3 scripts/validate.py
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FRONTMATTER = re.compile(r"^---\n(.*?)\n---\n", re.S)
errors: list[str] = []


def fail(msg: str) -> None:
    errors.append(msg)


def load_yaml(text: str, where: str):
    try:
        import yaml
    except ImportError:
        # Sin PyYAML, al menos se caza el fallo que motivó este script.
        for line in text.splitlines():
            key, _, value = line.partition(": ")
            if key and not key.startswith(" ") and ": " in value:
                fail(f"{where}: `{key}` contiene ': ' — rompe el escalar YAML")
        return None
    try:
        return yaml.safe_load(text)
    except Exception as exc:  # noqa: BLE001 — el mensaje del parser es el dato útil
        fail(f"{where}: YAML inválido — {str(exc).splitlines()[0]}")
        return None


manifests = {}
for rel in (".mcp.json", ".claude-plugin/plugin.json", ".claude-plugin/marketplace.json"):
    try:
        manifests[rel] = json.loads((ROOT / rel).read_text())
    except Exception as exc:  # noqa: BLE001
        fail(f"{rel}: JSON inválido — {exc}")

servers = set(manifests.get(".mcp.json", {}).get("mcpServers", {}))
plugin = manifests.get(".claude-plugin/plugin.json", {})
market = manifests.get(".claude-plugin/marketplace.json", {})

# Una versión distinta entre los dos manifiestos hace que el marketplace ofrezca
# una y el plugin declare otra, y el usuario no puede saber cuál tiene.
market_versions = {p.get("version") for p in market.get("plugins", [])}
if market_versions != {plugin.get("version")}:
    fail(
        f"versión descuadrada — plugin.json={plugin.get('version')} "
        f"marketplace.json={sorted(v for v in market_versions if v)}"
    )

for url in (s.get("url", "") for s in manifests.get(".mcp.json", {}).get("mcpServers", {}).values()):
    if not url.startswith("https://"):
        fail(f"servidor MCP sin https — {url!r}")

skill_dirs = sorted(p for p in (ROOT / "skills").iterdir() if p.is_dir())
for d in skill_dirs:
    where = f"skills/{d.name}/SKILL.md"
    md = d / "SKILL.md"
    if not md.exists():
        fail(f"{where}: no existe")
        continue
    m = FRONTMATTER.match(md.read_text())
    if not m:
        fail(f"{where}: sin frontmatter")
        continue
    fm = load_yaml(m.group(1), where)
    if fm is None:
        continue
    if fm.get("name") != d.name:
        fail(f"{where}: name={fm.get('name')!r} no coincide con el directorio {d.name!r}")
    if not fm.get("description"):
        fail(f"{where}: sin description (es lo que decide si la skill se activa)")
    if d.name not in servers:
        fail(f"{where}: no hay servidor MCP homónimo en .mcp.json")

    agent = d / "agents" / "openai.yaml"
    if agent.exists():
        cfg = load_yaml(agent.read_text(), f"skills/{d.name}/agents/openai.yaml")
        if cfg:
            for tool in cfg.get("dependencies", {}).get("tools", []):
                url = tool.get("url")
                declared = manifests[".mcp.json"]["mcpServers"].get(d.name, {}).get("url")
                if url and declared and url != declared:
                    fail(
                        f"skills/{d.name}/agents/openai.yaml: url {url} "
                        f"≠ la de .mcp.json {declared}"
                    )

for name in sorted(servers):
    if not (ROOT / "skills" / name).is_dir():
        fail(f".mcp.json declara {name} sin skill que lo guíe en skills/{name}/")

if errors:
    print("\n".join(f"✗ {e}" for e in errors))
    sys.exit(1)

print(f"✓ {len(manifests)} manifiestos, {len(skill_dirs)} skills, {len(servers)} servidores MCP")
