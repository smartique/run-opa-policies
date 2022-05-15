DATA_FILES:=utils.rego tfplan.json
CURRENT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
POLICY_DIR:="$(CURRENT_DIR)/policies/Infrastructure"
POLICY_TYPES:=$$(find $(POLICY_DIR) -mindepth 1 -maxdepth 1 -type d | awk -F "/" '{print $$NF}')

.PHONY: opa

opa:

# Generate Report
	echo "#### OPA Compliance Report" > REPORT.md; \
	echo "|Category | Total | Pass | Fail | Comments|" >> REPORT.md; \
	echo "| --- | :--- | :--- | :--- | :--- |" >> REPORT.md; \
	echo "-------------------------------------"; >> REPORT.md; \
	FAILURES=0; \
	for TYPE in $(POLICY_TYPES); do \
		for FILE in $(DATA_FILES); do cp $(POLICY_DIR)/$$FILE $(POLICY_DIR)/$$TYPE; done; \
		opa check --format json $(POLICY_DIR)/$$TYPE ; \
		RESULT=$$(opa test $(POLICY_DIR)/$$TYPE); \
		RESULT=$$(echo $$RESULT | sed 's/-//g'); \
		COUNT=$$(echo $$RESULT | grep -o " " | wc -l); \
		if [ $$COUNT -eq 1 ]; then \
			TOTAL=$$(echo $$RESULT | cut -d " " -f 2 | cut -d "/" -f 2); \
			PASS=$$(echo $$RESULT | cut -d " " -f 2 | cut -d "/" -f 1); \
			FAIL="0"; \
			printf "| %s | %s | %s | %s | %s |\n" $$TYPE $$TOTAL $$PASS $$FAIL "No Failures" >>  REPORT.md; \
		else \
			TOTAL=$$(echo $$RESULT | cut -d " " -f $$((COUNT+1)) | cut -d "/" -f 2); \
			FAIL=$$(echo $$RESULT | cut -d " " -f $$((COUNT+1)) | cut -d "/" -f 1); \
			PASS="$$(($$TOTAL - $$FAIL))"; \
			if [ $$PASS -eq 0 ]; then \
			 	COMMENT=$$(echo $$RESULT | cut -d " " -f 1-$$((COUNT-1))); \
			else \
				COMMENT=$$(echo $$RESULT | cut -d " " -f 1-$$((COUNT-3))); \
			fi; \
			FAILURES=$$(($$FAILURES + $$FAIL)); \
			printf "| %s | %s | %s | %s | %s |\n" $$TYPE $$TOTAL $$PASS $$FAIL "$$COMMENT" >>  REPORT.md; \
		fi ; \
		for FILE in $(DATA_FILES); do rm $(POLICY_DIR)/$$TYPE/$$FILE; done; \
	done; \
	cat REPORT.md; \
	if [ $$FAILURES -gt 0 ]; then \
		echo "Total Failures => $$FAILURES"; \
		exit 1; \
	fi
