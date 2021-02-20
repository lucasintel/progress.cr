require "./progress/*"

class Progress
  KiB = 1024
  MiB = 1024 * KiB
  GiB = 1024 * MiB

  DEFAULT_TEMPLATE = "{label} {bar} {step} {percent} [{elapsed}]"
  TEMPLATE_REGEX   = /{label}|{bar}|{total}|{step}|{percent}|{elapsed}/

  LEFT_BORDER_CHAR  = "["
  FILLED_CHAR       = "="
  EMPTY_CHAR        = " "
  RIGHT_BORDER_CHAR = "]"
  TOTAL_MASK        = "%5.1f"
  STEP_MASK         = "%5.1f"
  PERCENT_MASK      = "%4.f%%"
  CARRIAGE_RETURN   = '\r'
  NEW_LINE          = '\n'

  alias Num = Int32 | UInt32 | Int64 | UInt64 | Float32 | Float64

  def initialize(
    @width : Num = 100_u64,
    @total : Num = 100_u64,
    @step : Num = 0_u64,
    @left_border_char : String = LEFT_BORDER_CHAR,
    @filled_char : String = FILLED_CHAR,
    @empty_char : String = EMPTY_CHAR,
    @right_border_char : String = RIGHT_BORDER_CHAR,
    @label : String = "",
    @template : String = DEFAULT_TEMPLATE,
    @total_mask : String = TOTAL_MASK,
    @step_mask : String = STEP_MASK,
    @percent_mask : String = PERCENT_MASK,
    @humanize_bytes : Bool = true,
    @stream : IO::FileDescriptor = STDOUT
  )
    @start_at = Time.monotonic
  end

  def init : Nil
    @start_at = Time.monotonic
    render
  end

  def reset : Nil
    @step = 0_u64
    init
  end

  def tick(step : Num = 1_u64) : Nil
    new_step = @step + step
    set(new_step)
  end

  def set(step : Num) : Nil
    new_step =
      if step > @total
        @total
      elsif step < 0
        0_u64
      else
        step
      end

    @step = new_step
    render
  end

  def elapsed : String
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

  def started? : Bool
    @step > 0
  end

  def done? : Bool
    @total == @step
  end

  private def render : Nil
    percent = @step / @total

    bar_filled_integer = (@width * percent).to_i
    bar_empty_integer = (@width - bar_filled_integer).to_i

    bar = String.build do |str|
      str << @left_border_char
      str << @filled_char * bar_filled_integer
      str << @empty_char * bar_empty_integer
      str << @right_border_char
    end

    computed = @template.gsub(
      TEMPLATE_REGEX,
      {
        "{label}":   @label,
        "{bar}":     bar,
        "{total}":   format_bytes(@total, @total_mask),
        "{step}":    format_bytes(@step, @step_mask),
        "{percent}": format_percent(percent),
        "{elapsed}": elapsed,
      }
    )

    @stream.flush
    @stream.print(CARRIAGE_RETURN, computed)
    @stream.flush
    @stream.print(NEW_LINE) if done?
  end

  private def format_bytes(bytes : Num, mask : String) : String
    return bytes.to_s unless @humanize_bytes

    denominator, suffix = humanize_factor

    String.build do |str|
      str << mask % (bytes / denominator)
      str << suffix
    end
  end

  private def format_percent(percent : Num) : String
    @percent_mask % (percent * 100)
  end

  private def humanize_factor : Tuple(Num, String?)
    @humanize_factor ||=
      if @total < MiB
        {KiB, " KiB"}
      elsif @total > MiB && @total < GiB
        {MiB, " MiB"}
      else
        {GiB, " GiB"}
      end
  end
end
