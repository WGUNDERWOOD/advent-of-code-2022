all:
	@for f in day??.jl; do \
		time julia $$f; \
	done
