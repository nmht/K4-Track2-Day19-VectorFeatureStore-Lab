$ErrorActionPreference = 'Stop'
$env:PYTHONUTF8 = '1'

Write-Host "[lite] Day 19 lightweight setup" -ForegroundColor Cyan
Write-Host "[lite] Stack: fastembed + qdrant-client[memory] + rank-bm25 + feast(sqlite) + FastAPI"
Write-Host ""

# 1. Check Python (prefer stable 3.11/3.12/3.10 over 3.14 pre-release)
$pyCmd = $null
if (Get-Command py -ErrorAction SilentlyContinue) {
    & py -3.11 -c "import sys" 2>$null
    if ($LASTEXITCODE -eq 0) {
        $pyCmd = "py -3.11"
    } else {
        & py -3.12 -c "import sys" 2>$null
        if ($LASTEXITCODE -eq 0) {
            $pyCmd = "py -3.12"
        } else {
            & py -3.10 -c "import sys" 2>$null
            if ($LASTEXITCODE -eq 0) {
                $pyCmd = "py -3.10"
            } else {
                $pyCmd = "py"
            }
        }
    }
} else {
    $pyCmd = "python"
}

$pyVer = Invoke-Expression "$pyCmd -c `"import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')`""
Write-Host "[lite] system python is $pyVer (using $pyCmd)" -ForegroundColor Green

# 2. Create venv
if (Test-Path ".venv") {
    $existingVer = & .\.venv\Scripts\python.exe -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>$null
    if ((-not (Test-Path ".venv\Scripts\Activate.ps1")) -or ($existingVer -eq "3.14")) {
        Write-Host "[lite] Recreating .venv with stable Python..." -ForegroundColor Yellow
        Remove-Item -Recurse -Force .venv
    }
}

if (-not (Test-Path ".venv")) {
    Write-Host "[lite] Creating venv with $pyCmd -m venv" -ForegroundColor Yellow
    Invoke-Expression "$pyCmd -m venv .venv"
}

# 3. Activate venv
if (Test-Path ".venv\Scripts\Activate.ps1") {
    . .\.venv\Scripts\Activate.ps1
} else {
    Write-Error "[lite] Could not find venv activation script."
    exit 1
}

# 4. Install deps
$venvPyVer = & python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"
$needDillOverride = & python -c "import sys; print(1 if sys.version_info >= (3,14) else 0)"
Write-Host "[lite] venv Python $venvPyVer" -ForegroundColor Green

if ($needDillOverride -eq "1") {
    Write-Host "[lite] Python >= 3.14 -> applying dill>=0.4 override" -ForegroundColor Yellow
}

if (Get-Command uv -ErrorAction SilentlyContinue) {
    if ($needDillOverride -eq "1") {
        uv pip install --overrides overrides-py314.txt -r requirements.txt
    } else {
        uv pip install -r requirements.txt
    }
} else {
    pip install -U pip
    pip install -r requirements.txt
    if ($needDillOverride -eq "1") {
        pip install --upgrade "dill>=0.4,<1.0"
    }
}

# 5. Convert Jupytext sources
Write-Host "[lite] Converting Jupytext sources to .ipynb..." -ForegroundColor Yellow
$notebooks = Get-ChildItem -Path notebooks -Filter "[0-9]*.py"
foreach ($nb in $notebooks) {
    jupytext --to notebook --update $nb.FullName 2>$null
    if ($LASTEXITCODE -ne 0) {
        jupytext --to notebook $nb.FullName
    }
}

# 6. .env scaffold
if (-not (Test-Path ".env")) {
    Copy-Item .env.example .env
}

# 7. Seed corpus + golden set
Write-Host "[lite] Seeding corpus + golden set..." -ForegroundColor Yellow
python scripts\seed_corpus.py
Write-Host "  · seeding advanced-mission data (NB6 + NB8)…" -ForegroundColor Yellow
python scripts\gen_agent_queries.py
python scripts\gen_spend.py

# 8. Smoke test
Write-Host "[lite] Running smoke test..." -ForegroundColor Yellow
python scripts\verify_lite.py

Write-Host "`n[lite] Done. Activate the venv and start working:`n" -ForegroundColor Cyan
Write-Host "    .\.venv\Scripts\Activate.ps1"
Write-Host "    make api       # start FastAPI on :8000"
Write-Host "    make lab       # open Jupyter on :8888"
Write-Host "    make benchmark # Precision@10 + latency table`n"
Write-Host "Tip: read VIBE-CODING.md before starting NB1." -ForegroundColor Green
