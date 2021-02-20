# Progress

[![Built with Crystal 0.36.1](https://img.shields.io/badge/Crystal-0.36.1-%23333333)](https://crystal-lang.org/)
[![GitHub release](https://img.shields.io/github/release/kandayo/progress.cr.svg?label=Release)](https://github.com/kandayo/progress.cr/releases)
[![Specs](https://github.com/kandayo/progress.cr/workflows/Specs/badge.svg)](https://github.com/kandayo/progress.cr/actions)

Simple and customizable progress bar for Crystal.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     progress:
       github: kandayo/progress
   ```

2. Run `shards install`

## Usage

```crystal
require "progress"

# This is the default configuration; all arguments are optional.
progress = Progress.new(
  width: 100,
  total: 100,
  step: 0,
  left_border_char: "[",
  filled_char: "=",
  empty_char: " ",
  right_border_char: "]",
  label: "Neutron Star.pdf",
  template: "{label} {bar} {step} {percent} [{elapsed}]",
  percent_mask: "%4.f%%",
  total_mask: "%5.1f",
  step_mask: "%5.1f",
  humanize_bytes: true,
  stream: STDOUT
 )

# Optional: print an empty progress bar.
progress.init

until progress.done?
  # Ticks the progress bar by 1 unit.
  progress.tick(1)
  sleep 0.1
end

# Or you might set the step direcly.
progress.set(100)
progress.done? # => true

# Resets the progress bar state.
progress.reset
```

### Template options

 - `{label}`
 - `{bar}` — The progress bar.
 - `{total}`
 - `{step}` — Current step.
 - `{percent}` — Formatted percent (e.g. 100%)
 - `{elapsed}` — Elapsed time (e.g. 00:05)

By default, progress.cr tries to both humanize and format `total` and `step`.
For instance, `10_485_760` would printed as `10.0 MiB`. You might want to
customize `total_mask` and `step_mask`.

To opt-out this behaviour, set `humanize_bytes` to false.

## Examples

```
# {label} {step} {percent} [{elapsed}]
Neutron Star.pdf [====================================]   8.1 MiB  100%  [00:10]

# {bar} {percent}
[##############################] 100%

# {bar} {label}
[##############################] Neutron Star.pdf

# Unicode block characters
[██████████████████████] ⌛ Processing...
```

## Future

It definitely needs to be more customizable and flexible.

For now it works for my use case, and I hope it works for you as well.

## Contributing

1. Fork it (<https://github.com/kandayo/progress/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [kandayo](https://github.com/kandayo) - creator and maintainer
