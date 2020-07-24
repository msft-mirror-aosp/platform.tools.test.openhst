# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

.PHONY: help start

SHELL := /bin/bash
SRC_DIR ?= .
DST_DIR ?= .
PROTOC_DIR ?= .
PROTO_SRC_FILE ?= stress_test.proto

ifeq ($(OS),Windows_NT)
	detected_OS := Windows
	USER_NAME ?=
else
    detected_OS := $(shell uname)
	USER_NAME ?= $(shell whoami)
	ENV_PATH ?= $(shell pwd)
endif

.DEFAULT: help
help:
	@echo "make start"
	@echo "       prepare development environment, use only once"
	@echo "make proto-compile"
	@echo "       compile protubuf"
	@echo "make clean"
	@echo "       delete test result and cache directories"

start:
ifeq ($(detected_OS),Windows)
	@echo "please install python3 and pytyon3-pip manually"
	py -m pip install --upgrade pip
	py -m pip install --user virtualenv
	python -m venv .\env
endif
ifeq ($(detected_OS),Darwin)
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	sudo chown -R $(USER_NAME) /usr/local/bin /usr/local/etc /usr/local/sbin /usr/local/share
	chmod u+w /usr/local/bin /usr/local/etc /usr/local/sbin /usr/local/share
	brew install python3 protobuf sox
	python3 -m pip install --user virtualenv
	python3 -m venv env
endif
ifeq ($(detected_OS),Linux)
	sudo apt-get install python3 sox
	sudo apt install python3-pip
	python3 -m pip install --user --upgrade pip
	python3 -m pip install --user virtualenv
	sudo apt-get install python3-venv
	python3 -m venv env
	sudo apt install protobuf-compiler
endif

proto-compile: ${PROTO_SRC_FILE}
ifeq ($(detected_OS),Windows)
ifndef PROTOC_DIR
	@echo "Error! Please download protoc.exe from https://github.com/google/protobuf/releases/ and set PROTOC_DIR accordingly"
else
	$(PROTOC_DIR)/protoc.exe -I=${SRC_DIR} --python_out=${DST_DIR} ${SRC_DIR}/${PROTO_SRC_FILE}
endif
else
	protoc -I=${SRC_DIR} --python_out=${DST_DIR} ${SRC_DIR}/${PROTO_SRC_FILE}
endif

clean:
ifeq ($(detected_OS),Windows)
	@for /d %%x in (dsp_*) do rd /s /q "%%x"
	@for /d %%x in (enroll_*) do rd /s /q "%%x"
	@for /d %%x in (__pycache*) do rd /s /q "%%x"
else
	@rm -rf __pycache__
	@rm -rf dsp_*
	@rm -rf enroll*
endif
	@echo "cleanning completed"
