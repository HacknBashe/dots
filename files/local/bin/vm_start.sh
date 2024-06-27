#!/usr/bin/env bash

az account set --subscription "EA - Sandbox"
az vm start -g ea-sbx-dc01-containerdev-rg -n ea-sbx-dc01-containerdev-vm283
