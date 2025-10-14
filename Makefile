PHONY: github jaredwhalen

github:
	npm run build
	@if [ -f docs/CNAME ]; then cp docs/CNAME /tmp/CNAME.backup; fi
	rm -rf docs
	cp -r build docs
	@if [ -f /tmp/CNAME.backup ]; then mv /tmp/CNAME.backup docs/CNAME; fi
	touch docs/.nojekyll
	git add -A
	git commit -m "update github pages"
	git push