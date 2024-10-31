	
	STRIP ?= strip
	# check if user is root
	user = $(shell whoami)
	INSTALL_DIR = /usr/lib/lv2
	

	
	# set bundle name
	NAME = skh_record
	BUNDLE = $(NAME).lv2
	BUNDLE_MINI = $(NAME)_mini.lv2
	VER = 0.2

	

	# set compile flags
	CFLAGS += -I. -I./dsp  -fPIC -DPIC -O2 -Wall -funroll-loops `pkg-config --cflags sndfile`\
	-ffast-math -fomit-frame-pointer -fstrength-reduce -fdata-sections -Wl,--gc-sections \
	-pthread $(SSE_CFLAGS)
	CXXFLAGS += -std=c++11 $(CFLAGS)
	LDFLAGS += -I. -lm -shared -Llibrary -lm -fPIC -DPIC `pkg-config --libs sndfile`
	
	# invoke build files
	OBJECTS = $(NAME).cpp 
	GUI_OBJECTS = $(NAME)_x11ui.c
	#RES_OBJECTS = record.o
	## output style (bash colours)
	BLUE = "\033[1;34m"
	RED =  "\033[1;31m"
	NONE = "\033[0m"

.PHONY : mod all clean install uninstall 

all : check $(NAME)
	@mkdir -p ../$(BUNDLE)
	@cp ./*.ttl ../$(BUNDLE)
	@mv ./*.so ../$(BUNDLE)
	@if [ -f ../$(BUNDLE)/$(NAME).so ]; then echo $(BLUE)"build finish, now run make install"; \
	else echo $(RED)"sorry, build failed"; fi
	@echo $(NONE)

mod :  nogui modmini clean
	@mkdir -p ../$(BUNDLE)
	@cp -R ./MOD/* ../$(BUNDLE)
	@mv ./$(NAME).so ../$(BUNDLE)
	@if [ -f ../$(BUNDLE)/$(NAME).so ]; then echo $(BLUE)"build finish, now run make install"; \
	else echo $(RED)"sorry, build failed"; fi
	@echo $(NONE)

modmini :  noguimini
	@mkdir -p ../$(BUNDLE_MINI)
	@cp -R ./MOD-MINI/* ../$(BUNDLE_MINI)
	@mv ./$(NAME)_mini.so ../$(BUNDLE_MINI)
	@if [ -f ../$(BUNDLE_MINI)/$(NAME)_mini.so ]; then echo $(BLUE)"build finish, now run make install"; \
	else echo $(RED)"sorry, build failed"; fi
	@echo $(NONE)

check :
ifdef ARMCPU
	@echo $(RED)ARM CPU DEDECTED, please check the optimization flags
	@echo $(NONE)
endif

$(RESOURCEHEADER): $(RESOURCES_OBJ)
	rm -f $(RESOURCEHEADER)
	for f in $(RESOURCE_EXTLD); do \
		echo 'EXTLD('$${f}')' >> $(RESOURCEHEADER) ; \
	done

clean :
	rm -f *.a *.o *.so xresources.h
	@rm -f $(NAME).so
	@rm -rf ../$(BUNDLE)
	@rm -rf ../$(BUNDLE_MINI)
	#@rm -rf ./$(RES_OBJECTS)
	@echo ". ." $(BLUE)", clean up"$(NONE)

dist-clean :
	@rm -f $(NAME).so
	@rm -rf ../$(BUNDLE)
	@rm -rf ../$(BUNDLE_MINI)
	#@rm -rf ./$(RES_OBJECTS)
	@echo ". ." $(BLUE)", clean up"$(NONE)

install :
ifneq ("$(wildcard ../$(BUNDLE))","")
	@mkdir -p $(DESTDIR)$(INSTALL_DIR)/$(BUNDLE)
	cp -r ../$(BUNDLE)/* $(DESTDIR)$(INSTALL_DIR)/$(BUNDLE)
	@echo ". ." $(BLUE)", done"$(NONE)
	sudo systemctl restart pipedald
else
	@echo ". ." $(BLUE)", you must build first"$(NONE)
endif
ifneq ("$(wildcard ../$(BUNDLE_MINI))","")
	@mkdir -p $(DESTDIR)$(INSTALL_DIR)/$(BUNDLE_MINI)
	cp -r ../$(BUNDLE_MINI)/* $(DESTDIR)$(INSTALL_DIR)/$(BUNDLE_MINI)
endif

uninstall :
	@rm -rf $(INSTALL_DIR)/$(BUNDLE)
	@rm -rf $(INSTALL_DIR)/$(BUNDLE_MINI)
	@echo ". ." $(BLUE)", done"$(NONE)

$(NAME) : clean $(RES_OBJECTS)
	$(CXX) $(CXXFLAGS) $(OBJECTS) $(LDFLAGS) -o $(NAME).so
	#$(CC) $(CFLAGS) -Wl,-z,nodelete $(GUI_OBJECTS) -L. $(RESOURCES_LIB) $(GUI_LDFLAGS) -o $(NAME)_ui.so
	$(STRIP) -s -x -X -R .note.ABI-tag $(NAME).so
	#$(STRIP) -s -x -X -R .note.ABI-tag $(NAME)_ui.so

nogui : clean
	$(CXX) $(CXXFLAGS) $(OBJECTS) $(LDFLAGS) -o $(NAME).so
	$(STRIP) -s -x -X -R .note.ABI-tag $(NAME).so

noguimini : clean
	$(CXX) $(CXXFLAGS) $(OBJECTS) -DMINIREC=1 $(LDFLAGS) -o $(NAME)_mini.so
	$(STRIP) -s -x -X -R .note.ABI-tag $(NAME)_mini.so

doc:
	#pass
