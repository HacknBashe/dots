#!/usr/bin/env python3

from ml_nlp_proxy_py_utils.proxy_urls import Vendor, get_base_url
from ml_nlp_proxy_py_utils.auth import AuthProvider
import os

env_file = os.path.expanduser("~/.zshenv.local")
with open(env_file, "w") as f:
    f.write(f"export OPENAI_API_KEY={AuthProvider().get_token()}\n")
    f.write(f"export OPENAI_BASE_URL={get_base_url(Vendor.OPENAI)}\n")

