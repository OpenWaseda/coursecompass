.PHONY:	run stop deepclean start

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
	
start:	$(LOCKFILE)

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
	@if [ !  -s "$(LOCKFILE)" ]; then\
		/bin/echo -e "You have to run mongodb. To continue, type \"make start\" or \"make run\" in another shell." > /dev/stderr ; exit 1 ;\
	fi
	@whiptail --radiolist "Select gakubu to fetch:" 30 50 20 \
	 "111973" "政治経済学部" off\
	 "121973" "法学部" off\
	 "132002" "第一文学部" off\
	 "142002" "第二文学部" off\
	 "151949" "教育学部" off\
	 "161973" "商学部" off\
	 "171968" "理工学部" off\
	 "181966" "社会科学部" off\
	 "192000" "人間科学部" off\
	 "202003" "スポーツ科学部" off\
	 "212004" "国際教養学部" off\
	 "232006" "文化構想学部" off\
	 "242006" "文学部" off\
	 "252003" "人間科学部eスクール" off\
	 "262006" "基幹理工学部" off\
	 "272006" "創造理工学部" off\
	 "282006" "先進理工学部" off\
	 "311951" "政治学研究科" off\
	 "321951" "経済学研究科" off\
	 "331951" "法学研究科" off\
	 "342002" "文学研究科" off\
	 "351951" "商学研究科" off\
	 "371990" "教育学研究科" off\
	 "381991" "人間科学研究科" off\
	 "391994" "社会科学研究科" off\
	 "402003" "アジア太平洋研究科" off\
	 "422000" "国際情報通信研究科" off\
	 "432001" "日本語教育研究科" off\
	 "442003" "情報生産システム研究科" off\
	 "452003" "公共経営研究科" off\
	 "462004" "ファイナンス研究科" off\
	 "472004" "法務研究科" off\
	 "482005" "会計研究科" off\
	 "502005" "スポーツ科学研究科" off\
	 "512006" "基幹理工学研究科" off\
	 "522006" "創造理工学研究科" off\
	 "532006" "先進理工学研究科" off\
	 "542006" "環境・エネルギー研究科" off\
	 "552007" "教職研究科" off\
	 "562012" "国際コミュニケーション研究科" off\
	 "572015" "経営管理研究科" off\
	 "712001" "芸術学校" off\
	 "922006" "日本語教育研究センター" off\
	 "982007" "留学センター" off\
	 "9S2013" "グローバルエデュケーションセンター" off 2> tmp.txt
	@cat tmp.txt | node fetch
	@rm tmp.txt


