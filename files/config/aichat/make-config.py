from ruamel.yaml import YAML

from ml_nlp_proxy_py_utils.proxy_urls import Vendor, get_base_url
from ml_nlp_proxy_py_utils.auth import AuthProvider
from ml_nlp_proxy_py_utils.openai.proxy_headers import OpenAiProxyHeadersBuilder

config = {
    "clients": [
        {
            "type": "openai-compatible",
            "api_base": get_base_url(Vendor.OPENAI),
            "api_key": AuthProvider().get_token(),
            "name": "ml-nlp-gpt",
            # "models": [{"name": "gpt-4o-mini"}],
            "models": [{"name": "o4-mini"}],
        },
        {
            "type": "openai-compatible",
            "name": "ollama",
            "api_base": "http://localhost:11434/v1",
            "models": [
                {
                    "name": "gemma3:27b",
                    "max_input_tokens": 128000,
                    "supports_function_calling": True,
                }
            ],
        },
    ]
}

yaml = YAML()
yaml.indent(mapping=2, sequence=4, offset=2)
yaml.preserve_quotes = True

with open("config.yaml", "w") as f:
    yaml.dump(config, f)
