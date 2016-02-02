.PHONY: all plan

all: plan

plan:
	terraform plan -var "env=ci"
