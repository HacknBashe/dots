{
  lib,
  fetchurl,
  linkFarm,
}:
let
  baseUrl = "https://download.moonshine.ai/model/medium-streaming-en/quantized";

  files = {
    "adapter.ort" = "sha256-FjB0Qrf0Ip8vFRH8UbVFzslhblWHLFiPOil7vG9HYuo=";
    "cross_kv.ort" = "sha256-NUualVyut2i1KPRH8KNs5LhQyntFMZABZd8wTZeQT7o=";
    "decoder_kv.ort" = "sha256-+meqh1ISR/W/RNPkTU5JeOWMHxFCScPGkJyIJiQFZxU=";
    "decoder_kv_with_attention.ort" = "sha256-QJGd6V0IaQ2jqP9t8Uz1WzIgBG87dntKS3aeezKq8tI=";
    "encoder.ort" = "sha256-pfERZ6Yu72F4f+hBBFMlfW3bjrqQr0YalgTl8uk9UyI=";
    "frontend.ort" = "sha256-N4/opdcJChuauIu7H8lb3gEM3WTsI0GTUNLSPGdWNuk=";
    "streaming_config.json" = "sha256-KOg7eijpFHJpKgNeDa4xFkIq5DrrK+9e2CLETOibiK8=";
    "tokenizer.bin" = "sha256-aISzX9Y3fUxNMjNqC8FS82tk0eRbZQNoPNwjglCoRy0=";
  };
in
linkFarm "moonshine-model-medium-streaming-en" (
  lib.mapAttrsToList (name: hash: {
    inherit name;
    path = fetchurl {
      url = "${baseUrl}/${name}";
      inherit hash;
    };
  }) files
)
