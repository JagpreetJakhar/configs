#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$current_dir/utils.sh"

get_platform() {
  case $(uname -s) in
    Linux)
      if lspci | grep -iq nvidia; then
        echo "NVIDIA"
      elif command -v nvidia-smi >/dev/null 2>&1; then
        echo "NVIDIA"
      else
        echo "unknown"
      fi
      ;;
    Darwin)
      # TODO - Darwin/Mac compatibility
      ;;
    CYGWIN*|MINGW32*|MSYS*|MINGW*)
      # TODO - Windows compatibility
      ;;
  esac
}

get_gpu() {
  gpu=$(get_platform)
  if [[ "$gpu" == "NVIDIA" ]]; then
    usage=$(nvidia-smi --query-gpu=power.draw,power.limit --format=csv,noheader,nounits | \
            awk '{ draw += $0; max += $2 } END { printf("%dW/%dW\n", draw, max) }')
  else
    usage='unknown'
  fi
  normalize_percent_len "$usage"
}
get_gpu_name() {
  gpu=$(get_platform)
  if [[ "$gpu" == "NVIDIA" ]]; then
    full_name=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -n 1)
    # Remove leading 'NVIDIA GeForce ' and trailing ' Laptop GPU' if present
    name=$(echo "$full_name" | sed 's/^NVIDIA GeForce //' | sed 's/ Laptop GPU$//')
    echo "$name"
  else
    echo "$gpu"
  fi
}
get_ram() {
  gpu=$(get_platform)
  if [[ "$gpu" == "NVIDIA" ]]; then
    usage=$(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | \
            awk '{ used += $0; total += $2 } END { printf("%dGB/%dGB\n", used / 1024, total / 1024) }')
  else
    usage='unknown'
  fi
  normalize_percent_len "$usage"
}
get_util() {
  gpu=$(get_platform)
  if [[ "$gpu" == "NVIDIA" ]]; then
    usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | \
            awk '{ sum += $0 } END { printf("%d%%\n", sum / NR) }')
  elif [[ "$gpu" == "apple" ]]; then
    usage="$(sudo powermetrics --samplers gpu_power -i500 -n 1 | grep 'active residency' | \
           sed 's/[^0-9.%]//g' | sed 's/[%].*$//g')%"
  else
    usage='unknown'
  fi
  normalize_percent_len "$usage"
}

main() {
  RATE=$(get_tmux_option "@kanagawa-refresh-rate" 5)
  gpu_label=$(get_gpu_name)
  gpu_power=$(get_gpu)
  gpu_ram=$(get_ram)
  gpu_util=$(get_util)
  echo "$gpu_label$gpu_util$gpu_ram$gpu_power"
  sleep "$RATE"
}

main

