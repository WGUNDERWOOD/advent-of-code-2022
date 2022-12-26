all:
	@for f in day??.jl; do \
		julia -t 8 $$f; \
	done
