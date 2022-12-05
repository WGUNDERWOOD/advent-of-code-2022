all:
	@for f in day??.jl; do \
		julia $$f; \
	done
