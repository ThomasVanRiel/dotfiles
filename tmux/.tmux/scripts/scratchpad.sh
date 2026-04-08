#!/bin/sh
# Bootstrap and launch the IPython scratchpad
# Called by tmux as the session command; setup output is visible in the popup

VENV="$HOME/.local/share/scratchpad-venv"

if [ ! -d "$VENV" ]; then
  echo "Setting up scratchpad environment..."
  python3 -m venv "$VENV"

  echo "Installing packages..."
  "$VENV/bin/pip" install ipython numpy sympy pandas matplotlib plotext

  echo "Configuring IPython profile..."
  mkdir -p "$VENV/ipython_profile/profile_default/startup"
  cat > "$VENV/ipython_profile/profile_default/startup/00-imports.py" << 'EOF'
import numpy as np
import sympy as sp
import pandas as pd
import matplotlib.pyplot as plt
import plotext as pltx
pltx.theme("clear")
EOF

  echo "Done! Starting IPython..."
fi

exec "$VENV/bin/ipython" --no-banner --ipython-dir="$VENV/ipython_profile"
