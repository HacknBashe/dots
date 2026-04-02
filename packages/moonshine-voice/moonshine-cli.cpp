// moonshine-cli: Minimal CLI wrapper around the Moonshine C++ API.
// Reads a 16-bit PCM WAV file and prints the transcribed text to stdout.

#include "moonshine-cpp.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

struct WavHeader {
  char riff[4];
  uint32_t fileSize;
  char wave[4];
  char fmt[4];
  uint32_t fmtSize;
  uint16_t audioFormat;
  uint16_t numChannels;
  uint32_t sampleRate;
  uint32_t byteRate;
  uint16_t blockAlign;
  uint16_t bitsPerSample;
};

static bool loadWav(const char *path, std::vector<float> &audioData,
                    int32_t &sampleRate) {
  std::ifstream file(path, std::ios::binary);
  if (!file.is_open()) {
    std::cerr << "Error: Cannot open file: " << path << std::endl;
    return false;
  }

  WavHeader header;
  file.read(reinterpret_cast<char *>(&header), sizeof(WavHeader));

  if (std::memcmp(header.riff, "RIFF", 4) != 0 ||
      std::memcmp(header.wave, "WAVE", 4) != 0) {
    std::cerr << "Error: Not a valid WAV file: " << path << std::endl;
    return false;
  }

  if (header.audioFormat != 1) {
    std::cerr << "Error: Only PCM WAV files are supported (got format "
              << header.audioFormat << ")" << std::endl;
    return false;
  }

  sampleRate = static_cast<int32_t>(header.sampleRate);

  // Skip to the data chunk
  char chunkId[4];
  uint32_t chunkSize;
  while (file.read(chunkId, 4)) {
    file.read(reinterpret_cast<char *>(&chunkSize), 4);
    if (std::memcmp(chunkId, "data", 4) == 0) {
      break;
    }
    file.seekg(chunkSize, std::ios::cur);
  }

  if (file.eof()) {
    std::cerr << "Error: No data chunk found in WAV file" << std::endl;
    return false;
  }

  size_t numSamples = chunkSize / (header.bitsPerSample / 8) / header.numChannels;
  audioData.resize(numSamples);

  if (header.bitsPerSample == 16) {
    std::vector<int16_t> rawData(numSamples * header.numChannels);
    file.read(reinterpret_cast<char *>(rawData.data()),
              chunkSize);
    for (size_t i = 0; i < numSamples; ++i) {
      // Take first channel if stereo
      audioData[i] = static_cast<float>(rawData[i * header.numChannels]) / 32768.0f;
    }
  } else if (header.bitsPerSample == 32) {
    std::vector<float> rawData(numSamples * header.numChannels);
    file.read(reinterpret_cast<char *>(rawData.data()), chunkSize);
    for (size_t i = 0; i < numSamples; ++i) {
      audioData[i] = rawData[i * header.numChannels];
    }
  } else {
    std::cerr << "Error: Unsupported bit depth: " << header.bitsPerSample
              << std::endl;
    return false;
  }

  return true;
}

static moonshine::ModelArch parseArch(const char *arch) {
  if (strcmp(arch, "tiny") == 0) return moonshine::ModelArch::TINY;
  if (strcmp(arch, "base") == 0) return moonshine::ModelArch::BASE;
  if (strcmp(arch, "tiny-streaming") == 0) return moonshine::ModelArch::TINY_STREAMING;
  if (strcmp(arch, "base-streaming") == 0) return moonshine::ModelArch::BASE_STREAMING;
  if (strcmp(arch, "small-streaming") == 0) return moonshine::ModelArch::SMALL_STREAMING;
  if (strcmp(arch, "medium-streaming") == 0) return moonshine::ModelArch::MEDIUM_STREAMING;
  std::cerr << "Error: Unknown model architecture: " << arch << std::endl;
  std::cerr << "Valid options: tiny, base, tiny-streaming, base-streaming, "
               "small-streaming, medium-streaming"
            << std::endl;
  std::exit(1);
}

static void printUsage(const char *prog) {
  std::cerr << "Usage: " << prog
            << " [-m <model_dir>] [-a <arch>] <input.wav>"
            << std::endl;
  std::cerr << std::endl;
  std::cerr << "Options:" << std::endl;
#ifdef DEFAULT_MODEL_PATH
  std::cerr << "  -m <path>    Path to model directory (default: built-in)"
            << std::endl;
#else
  std::cerr << "  -m <path>    Path to model directory (required)" << std::endl;
#endif
  std::cerr << "  -a <arch>    Model architecture (default: medium-streaming)"
            << std::endl;
  std::cerr << "  -otxt        Write output to a text file" << std::endl;
  std::cerr << "  -of <prefix> Output file prefix (used with -otxt)" << std::endl;
}

int main(int argc, char *argv[]) {
  const char *modelPath = nullptr;
  const char *archStr = "medium-streaming";
  const char *inputFile = nullptr;
  const char *outputPrefix = nullptr;
  bool outputTxt = false;

  for (int i = 1; i < argc; ++i) {
    if (strcmp(argv[i], "-m") == 0 && i + 1 < argc) {
      modelPath = argv[++i];
    } else if (strcmp(argv[i], "-a") == 0 && i + 1 < argc) {
      archStr = argv[++i];
    } else if (strcmp(argv[i], "-otxt") == 0) {
      outputTxt = true;
    } else if (strcmp(argv[i], "-of") == 0 && i + 1 < argc) {
      outputPrefix = argv[++i];
    } else if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
      printUsage(argv[0]);
      return 0;
    } else if (argv[i][0] != '-') {
      inputFile = argv[i];
    } else {
      std::cerr << "Unknown option: " << argv[i] << std::endl;
      printUsage(argv[0]);
      return 1;
    }
  }

  if (!modelPath) {
#ifdef DEFAULT_MODEL_PATH
    modelPath = DEFAULT_MODEL_PATH;
#else
    std::cerr << "Error: No model path specified and no built-in default."
              << std::endl;
    printUsage(argv[0]);
    return 1;
#endif
  }

  if (!inputFile) {
    printUsage(argv[0]);
    return 1;
  }

  std::vector<float> audioData;
  int32_t sampleRate;
  if (!loadWav(inputFile, audioData, sampleRate)) {
    return 1;
  }

  moonshine::ModelArch arch = parseArch(archStr);

  try {
    moonshine::Transcriber transcriber(modelPath, arch);
    moonshine::Transcript transcript =
        transcriber.transcribeWithoutStreaming(audioData, sampleRate);

    std::string result;
    for (const auto &line : transcript.lines) {
      if (!result.empty()) {
        result += " ";
      }
      result += line.text;
    }

    if (outputTxt && outputPrefix) {
      std::string outPath = std::string(outputPrefix) + ".txt";
      std::ofstream outFile(outPath);
      if (outFile.is_open()) {
        outFile << result << std::endl;
        outFile.close();
      } else {
        std::cerr << "Error: Cannot write to " << outPath << std::endl;
        return 1;
      }
    } else {
      std::cout << result << std::endl;
    }
  } catch (const moonshine::MoonshineException &e) {
    std::cerr << "Moonshine error: " << e.what() << std::endl;
    return 1;
  }

  return 0;
}
