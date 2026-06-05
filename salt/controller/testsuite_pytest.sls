# Salt state: configure openSUSE Leap 15.6 controller for Uyuni testsuite Python/pytest runner
# Requirements from: testsuite/README_PYTHON.md + testsuite/pyproject.toml

# ── 1. System packages ────────────────────────────────────────────────────────
#
# chromium: system browser used by Playwright (playwright install-deps is
#   Debian/Ubuntu only — on openSUSE/SLES use the system Chromium package)

testsuite_system_packages:
  pkg.installed:
    - pkgs:
      - python311
      - python311-pip
      - chromium
      - nodejs20

# ── 2. Python dependencies via pip ───────────────────────────────────────────

testsuite_pip_packages:
  pip.installed:
    - pkgs:
      - pytest>=7.4
      - pytest-bdd>=7.0
      - playwright>=1.40
      - paramiko>=3.4
      - httpx>=0.27
      - prometheus-client>=0.20
      - redis>=5.0
      - pytest-html>=4.0
    - bin_env: /usr/bin/python3.11
    - require:
      - pkg: testsuite_system_packages

# ── 3. Node.js dependencies for Cucumber HTML report generation ──────────────
#
# index.cjs uses multiple-cucumber-html-reporter as a library (require()).
# npm20 is the npm binary provided by the nodejs20 package on openSUSE/SLES.

testsuite_npm_packages:
  cmd.run:
    - name: npm20 install
    - cwd: /root/spacewalk/testsuite
    - require:
      - pkg: testsuite_system_packages

# ── 4. Playwright environment variables (system-wide) ────────────────────────
#
# Tells Playwright to use the system Chromium binary and skip its own browser
# download (which would fail on openSUSE with no apt-get available).

testsuite_playwright_env:
  file.managed:
    - name: /etc/profile.d/testsuite-playwright.sh
    - mode: '0644'
    - contents: |
        export PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium
        export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    - require:
      - pkg: testsuite_system_packages
