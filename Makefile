.PHONY: validate preflight plan deploy verify cleanup
validate:
	python3 scripts/validate.py
preflight:
	bash scripts/preflight.sh
plan:
	bash scripts/deploy.sh what-if
deploy:
	bash scripts/deploy.sh deploy
verify:
	bash scripts/verify.sh
cleanup:
	bash scripts/cleanup.sh
