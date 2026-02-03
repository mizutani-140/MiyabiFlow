SHELL := /usr/bin/env bash

.PHONY: ci test lint typecheck security

ci:
	bash scripts/ci/run_ci.sh --mode ci

test:
	bash scripts/ci/run_ci.sh --mode test-only

lint:
	@echo "Use .ai/config/ci.json or package manager scripts to define lint"

typecheck:
	@echo "Use .ai/config/ci.json or package manager scripts to define typecheck"

security:
	bash scripts/security/scan.sh
