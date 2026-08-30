#!/usr/bin/env bash
# ORIGINAL FOLEY for Project 001 - synthesised from oscillators and noise, not sampled. The MCP audio model is
# speech-only, so every sound here is built by hand in ffmpeg and we own it outright.
# MOBILE LAW (our own research): phone speakers roll off below ~1kHz, so each cue carries an audible mid/high
# component as well as its low body - it reads on a phone AND has weight on desktop.
cd "$(dirname "$0")"
R=44100
fail=0

run() { name="$1"; shift; if ffmpeg -y "$@" 2>/dev/null; then echo "  built $name"; else echo "  FAILED $name"; fail=1; fi; }

# THE THRESHOLD'S AIR - ambient bed: brown-noise body + a breathing mid band + very slow tremolo.
run amb_threshold.mp3 -f lavfi -i "anoisesrc=c=brown:r=$R:d=20" -f lavfi -i "anoisesrc=c=pink:r=$R:d=20" \
 -filter_complex "[0:a]lowpass=f=220,volume=1.6[low];[1:a]bandpass=f=520:w=380,volume=0.32,tremolo=f=0.11:d=0.45[mid];[low][mid]amix=inputs=2:duration=shortest,tremolo=f=0.1:d=0.25,afade=t=in:d=1.5,afade=t=out:st=18.5:d=1.5,volume=0.9" \
 -codec:a libmp3lame -b:a 128k amb_threshold.mp3

# THE WATCHER MOVES - a heavy dragging step: dull body thump under a noise scrape.
run watcher_step.mp3 -f lavfi -i "sine=frequency=62:duration=1.4:r=$R" -f lavfi -i "anoisesrc=c=brown:r=$R:d=1.4" \
 -filter_complex "[0:a]volume=0.9,afade=t=out:st=0.10:d=0.30[thump];[1:a]bandpass=f=900:w=1100,volume=0.55,afade=t=in:d=0.20,afade=t=out:st=0.55:d=0.55[scrape];[thump][scrape]amix=inputs=2:duration=longest,aecho=0.7:0.5:120:0.25,volume=1.4" \
 -codec:a libmp3lame -b:a 128k watcher_step.mp3

# THE SURGE - the power dying: bright electrical crack + descending sweep + low collapse. The signature moment.
run surge_death.mp3 -f lavfi -i "sine=frequency=420:duration=2.2:r=$R" -f lavfi -i "anoisesrc=c=white:r=$R:d=2.2" -f lavfi -i "sine=frequency=48:duration=2.2:r=$R" \
 -filter_complex "[0:a]volume=0.5,highpass=f=180,afade=t=out:st=0.05:d=1.5[sweep];[1:a]highpass=f=1400,volume=0.75,afade=t=out:st=0:d=0.22[crack];[2:a]volume=1.0,afade=t=in:d=0.05,afade=t=out:st=0.35:d=1.6[boom];[crack][sweep][boom]amix=inputs=3:duration=longest,aecho=0.8:0.6:220:0.35,volume=1.5" \
 -codec:a libmp3lame -b:a 128k surge_death.mp3

# THE BREAKER - a heavy mechanical throw: metallic clank (phone-safe) + a solid low seat.
run breaker_throw.mp3 -f lavfi -i "anoisesrc=c=white:r=$R:d=0.9" -f lavfi -i "sine=frequency=95:duration=0.9:r=$R" \
 -filter_complex "[0:a]bandpass=f=2100:w=1800,volume=0.8,afade=t=out:st=0:d=0.14[clank];[1:a]volume=0.9,afade=t=out:st=0.02:d=0.28[seat];[clank][seat]amix=inputs=2:duration=longest,aecho=0.75:0.5:90:0.2,volume=1.4" \
 -codec:a libmp3lame -b:a 128k breaker_throw.mp3

# THE CATCH - it reaches you: a muffled body impact, deliberately NOT a scream (Bible: no cheap tricks).
run catch_impact.mp3 -f lavfi -i "anoisesrc=c=brown:r=$R:d=1.2" -f lavfi -i "sine=frequency=55:duration=1.2:r=$R" \
 -filter_complex "[0:a]lowpass=f=700,volume=1.0,afade=t=out:st=0:d=0.5[hit];[1:a]volume=1.1,afade=t=out:st=0:d=0.7[body];[hit][body]amix=inputs=2:duration=longest,aecho=0.8:0.7:300:0.4,volume=1.5" \
 -codec:a libmp3lame -b:a 128k catch_impact.mp3

echo "--- levels (must not be silent; mean around -20dB is healthy) ---"
for f in amb_threshold.mp3 watcher_step.mp3 surge_death.mp3 breaker_throw.mp3 catch_impact.mp3; do
  [ -f "$f" ] || continue
  printf "%-20s %5sKB  " "$f" "$(( $(stat -c%s "$f") / 1024 ))"
  ffmpeg -i "$f" -af volumedetect -f null - 2>&1 | grep -E "mean_volume|max_volume" | sed 's/.*] //' | tr '\n' ' '
  echo ""
done
# (exit moved to end of file)

# NORMALISE: bring every cue to a consistent headroom (peak ~-3dB). In-engine Volume then does the mixing;
# shipping a source at -44dB mean would be inaudible on a phone no matter what Volume we set.
echo "--- normalising ---"
for f in amb_threshold.mp3 watcher_step.mp3 surge_death.mp3 breaker_throw.mp3 catch_impact.mp3; do
  [ -f "$f" ] || continue
  mx=$(ffmpeg -i "$f" -af volumedetect -f null - 2>&1 | grep max_volume | sed 's/.*max_volume: //;s/ dB//')
  gain=$(python -c "print(round(-3.0 - ($mx), 2))")
  ffmpeg -y -i "$f" -af "volume=${gain}dB" -codec:a libmp3lame -b:a 128k "n_$f" 2>/dev/null && mv "n_$f" "$f"
  printf "%-20s boosted %+6sdB -> " "$f" "$gain"
  ffmpeg -i "$f" -af volumedetect -f null - 2>&1 | grep -E "mean_volume|max_volume" | sed 's/.*] //' | tr '\n' ' '
  echo ""
done
