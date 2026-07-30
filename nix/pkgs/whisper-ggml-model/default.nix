{
  fetchurl,
  model ? "base.en",
  hash ? "sha256-oDd5yG3zMjB19eeWyyzlAp8A7Ihp7uP9+4l6/jbG0AI=",
}:
# whisper.cpp GGML weights, fetched by hash so the model is part of the closure
# instead of something `whisrs setup` has to download imperatively at runtime.
# To switch models, pass a new `model`/`hash` pair (hashes are per-file):
#   nix store prefetch-file https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin
fetchurl {
  name = "ggml-${model}.bin";
  url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-${model}.bin";
  inherit hash;
}
