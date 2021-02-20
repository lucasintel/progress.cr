require "./progress/*"

class Progress
  KiB = 1024
  MiB = 1024 * KiB
  GiB = 1024 * MiB

  DEFAULT_TEMPLATE = " + {label} {bar} {step} {percent} [{elapsed}]"
  TEMPLATE_REGEX   = /{label}|{bar}|{total}|{step}|{percent}|{elapsed}/

  LEFT_BORDER_CHAR  = "["
  FILLED_CHAR       = "="
  EMPTY_CHAR        = " "
  RIGHT_BORDER_CHAR = "]"
  TOTAL_MASK        = "%5.1f MiB"
  STEP_MASK         = "%5.1f MiB"
  PERCENT_MASK      = "%4.f%%"
  CARRIAGE_RETURN   = '\r'
  NEW_LINE          = '\n'

  def initialize(
    @width : Number = 100,
    @total : Number = 100,
    @step : Number = 0,
    @left_border_char : String = LEFT_BORDER_CHAR,
    @filled_char : String = FILLED_CHAR,
    @empty_char : String = EMPTY_CHAR,
    @right_border_char : String = RIGHT_BORDER_CHAR,
    @label : String = "",
    @template : String = DEFAULT_TEMPLATE,
    @total_mask : String = TOTAL_MASK,
    @step_mask : String = STEP_MASK,
    @percent_mask : String = PERCENT_MASK
  )
    @start_at = Time.monotonic
    @range = 0..@total
  end

  def init
    @step = 0
    render
  end

  def reset
    init
  end

  def tick(step : Number)
    @step += step
    render
  end

  def set(step : Number)
    raise OverflowError.new unless @range.includes?(step)

    @step = step
    render
  end

  def elapsed
    time = Time.monotonic - @start_at

    String.build do |str|
      if time.hours.abs > 0
        str << '0' if time.hours < 10
        str << ':'
      end

      str << '0' if time.minutes < 10
      str << time.minutes.abs
      str << ':'
      str << '0' if time.seconds < 10
      str << time.seconds.abs
    end
  end

  def started?
    @step > 0
  end

  def done?
    @total == @step
  end

  private def render
    percent = @step / @total
    filled_int = (@width * percent).to_i
    empty_int = (@width - filled_int).to_i

    formatted_percent = @percent_mask % (percent * 100)
    formatted_step = @step_mask % (@step / MiB)

    bar = String.build do |str|
      str << @left_border_char
      str << @filled_char * filled_int
      str << @empty_char * empty_int
      str << @right_border_char
    end

    computed = @template.gsub(
      TEMPLATE_REGEX,
      {
        "{label}":   @label,
        "{bar}":     bar,
        "{total}":   @total,
        "{step}":    formatted_step,
        "{percent}": formatted_percent,
        "{elapsed}": elapsed,
      }
    )

    STDOUT.flush
    STDOUT.print(CARRIAGE_RETURN, computed)
    STDOUT.flush
    STDOUT.print(NEW_LINE) if done?
  end
end
