.PHONY:	run stop deepclean

ifeq (\$(UNAME),Darwin)
BROWSER=open
else
BROWSER=xdg-open
endif
#BROWSER=chromium
SETTINGS_MONGO=settings/database.json
SETTINGS_APP=settings/web.json
NODE_BIN=$(if `which nodemon`, "nodemon", "node")
DBPATH=dbfile
LOCKFILE=$(DBPATH)/mongod.lock
MONGO_PORT=`cat $(SETTINGS_MONGO)|sed -ne '/"port"\s*:/p' | sed -e 's/^.*"port"\s*:[^0-9]*\([0-9]*\)[^0-9]*$$/\1/'`
APP_PORT=`cat $(SETTINGS_APP)|sed -ne '/"port"\s*:/p' | sed -e 's/^.*"port"\s*:[^0-9]*\([0-9]*\)[^0-9]*$$/\1/'`

run:	$(LOCKFILE) app.js node_modules
	@sh -c "sleep 0.5 ; $(BROWSER) http://localhost:$(APP_PORT)/ &> /dev/null " &
	@$(NODE_BIN) app.js ; $(MAKE) stop

stop:
	@echo stopping mongodb...
	@if [ -e "$(LOCKFILE)" -a -s "$(LOCKFILE)" ]; then\
		mongod --dbpath $(DBPATH) --shutdown;\
	fi
	@rm -rf $(LOCKFILE)
	@echo mongodb stopped.
	
$(LOCKFILE):
	@echo "running mongodb (port $(MONGO_PORT))..."
	@mkdir -p $(DBPATH)
	@sh -c "mongod --port $(MONGO_PORT) --dbpath $(DBPATH) &" > /dev/null
	@echo mongodb started.

node_modules:
	npm install

deepclean:
	rm -rf node_modules $(DBPATH) package-lock.json

fetch:
	@whiptail --checklist "Select gakubu to fetch:" 30 50 20 \
	 "111973" "政治経済学部" on\
	 "121973" "法学部" on\
	 "132002" "第一文学部" on\
	 "142002" "第二文学部" on\
	 "151949" "教育学部" on\
	 "161973" "商学部" on\
	 "171968" "理工学部" on\
	 "181966" "社会科学部" on\
	 "192000" "人間科学部" on\
	 "202003" "スポーツ科学部" on\
	 "212004" "国際教養学部" on\
	 "232006" "文化構想学部" on\
	 "242006" "文学部" on\
	 "252003" "人間科学部eスクール" on\
	 "262006" "基幹理工学部" on\
	 "272006" "創造理工学部" on\
	 "282006" "先進理工学部" on\
	 "311951" "政治学研究科" on\
	 "321951" "経済学研究科" on\
	 "331951" "法学研究科" on\
	 "342002" "文学研究科" on\
	 "351951" "商学研究科" on\
	 "371990" "教育学研究科" on\
	 "381991" "人間科学研究科" on\
	 "391994" "社会科学研究科" on\
	 "402003" "アジア太平洋研究科" on\
	 "422000" "国際情報通信研究科" on\
	 "432001" "日本語教育研究科" on\
	 "442003" "情報生産システム研究科" on\
	 "452003" "公共経営研究科" on\
	 "462004" "ファイナンス研究科" on\
	 "472004" "法務研究科" on\
	 "482005" "会計研究科" on\
	 "502005" "スポーツ科学研究科" on\
	 "512006" "基幹理工学研究科" on\
	 "522006" "創造理工学研究科" on\
	 "532006" "先進理工学研究科" on\
	 "542006" "環境・エネルギー研究科" on\
	 "552007" "教職研究科" on\
	 "562012" "国際コミュニケーション研究科" on\
	 "572015" "経営管理研究科" on\
	 "712001" "芸術学校" on\
	 "922006" "日本語教育研究センター" on\
	 "982007" "留学センター" on\
	 "9S2013" "グローバルエデュケーションセンター" on ; :


