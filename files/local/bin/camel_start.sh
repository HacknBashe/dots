#!/usr/bin/env bash
az account set --subscription "Auto Extract Integration Test"
az vm start --name ae-camel -g productivity
