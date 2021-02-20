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

  # Initializes the timer and render the progress bar.
  def init : Nil
    @start_at = Time.monotonic
    render
  end

  # Ticks the progress bar by *step*. The step can be either positive or
  # negative.
  #
  # ```
  # progress = Progress.new(total: 10)
  # progress.tick(10)
  # progress.done? # => true
  # ```
  def tick(step : Num) : Nil
    new_step = @step + step
    set(new_step)
  end

  # Sets the progress bar *step* directly. If the value overflows the progress
  # bar capacity, the remaining will be ignored.
  #
  # ```
  # progress = Progress.new(total: 10)
  # progress.set(10)
  # progress.done? # => true
  # ```
  def set(step : Num) : Nil
    new_step = if step > @total
                 @total
               elsif step < 0
                 0_u64
               else
                 step
               end

    @step = new_step
    render
  end

  # Returns the elapsed time since the progress bar was last initialized.
  #
  # ```
  # progress = Progress.new
  # sleep 5
  # progress.elapsed_time # => 00:05
  # ```
  def elapsed_time : String
    time = Time.monotonic - @start_at
    return time.to_s if time.hours.abs > 0

    String.build do |str|
      str << '0' if time.minutes < 10
      str << time.minutes.abs
      str << ':'
      str << '0' if time.seconds < 10
      str << time.seconds.abs
    end
  end

  # Returns true if the progress bar is running, else false. This method has
  # no effect right now, as it always return true.
  def started? : Bool
    @step > 0
  end

  # Returns true if the progress bar is done, else false.
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
        "{elapsed}": elapsed_time,
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
