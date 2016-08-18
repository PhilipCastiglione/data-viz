class Presenter
  COLORS = ["#3c368e", "#fcb71e", "#6d0c67", "#fff500", "#d24d8e", "#eb261a", "#16d97a", "#f05620", "#1eb7b2", "#ffa948", "#0062b1"].freeze
  LEARN = "Extra-work Learning".freeze

  attr_accessor :date, :tasks, :summary_tasks, :dates, :daily_details, :daily_summary, :daily_learning, :weekly_learning

  def initialize(date)
    self.date = date
    self.tasks = []
    self.summary_tasks = []
    self.dates = []

    self.daily_details = {}
    self.daily_summary = {}
    self.daily_learning = {}
    self.weekly_learning = {}
  end

  def generate_charts
    extract_tasks_and_dates

    prepare_data_structure

    populate_data

    generate_report(daily_summary, "Daily Timesheet Summary")
    generate_report(daily_details, "Daily Timesheet Details")
    generate_report(daily_learning, "Daily Learning", average: true)
    generate_report(weekly_learning, "Weekly Learning", average: true, weekly: true)
  end

  private

  def extract_tasks_and_dates
    load_csv do |row|
      self.tasks << detail_subset(row["Task"])
      self.summary_tasks << summary_subset(row["Task"])
      self.dates << row["Date"]
    end
  end

  def prepare_data_structure
    self.tasks.uniq!
    self.summary_tasks.uniq!
    self.dates.uniq!

    self.daily_details = tasks.reduce({}) { |h, t| h.merge(t => [0] * dates.size) }
    self.daily_summary = summary_tasks.reduce({}) { |h, t| h.merge(t => [0] * dates.size) }
    self.daily_learning = { LEARN => [0] * dates.size }
    self.weekly_learning = { LEARN => [0] * (dates.size / 7.0).ceil }
  end

  def populate_data
    day_num = 0
    day = ''
    load_csv do |row|
      if row["Date"] != day
        day = row["Date"]
        day_num += 1
      end

      daily_details[detail_subset(row["Task"])][day_num - 1] += row["Hours"].to_f
      daily_summary[summary_subset(row["Task"])][day_num - 1] += row["Hours"].to_f
    end
    daily_learning[LEARN] = daily_details[LEARN]
    daily_learning[LEARN].each_with_index { |hours, i| weekly_learning[LEARN][i / 7] += hours }
  end

  def load_csv(&block)
    CSV.foreach("./csv/#{date}.csv",{ headers: true }, &block)
  end

  def detail_subset(task)
    case task
    when /^Work/                      then "Work"
    when /Leisure/, /Sociali/         then "Fun"
    else
      task
    end
  end

  def summary_subset(task)
    case task
    when /^Work/                      then "Work"
    when /Dead/, /Travel/, /Chore/    then "Boring Life Things"
    when /Leisure/, /Vino/, /Sociali/ then "Fun"
    else
      task
    end
  end

  def generate_report(content, name, options = {})
    chart = Gruff::StackedBar.new(1600)
    chart.label_stagger_height = 20
    chart.replace_colors(COLORS)
    chart.y_axis_increment = options[:weekly] ? 4 : 1
    chart.legend_font_size = 16
    chart.marker_font_size = 14

    chart.title = "#{name} Report"
    chart.labels = if options[:weekly]
                     weeks = []
                     (dates.size / 7.0).ceil.times { |i| weeks << dates[i * 7] }
                     Hash[(0...weeks.size).zip weeks.map { |d| d.slice(5, 9) }]
                   else
                     Hash[(0...dates.size).zip dates.map { |d| d.slice(5, 9) }]
                   end

    if options[:average]
      chart.instance_variable_set(:@additional_line_colors, ["#1eb7b2"])
      chart.additional_line_values << content[LEARN].inject(:+) / content[LEARN].size.to_f
    end

    # put sleep first if it's there
    chart.data("Sleep", content.delete("Sleep")) if content["Sleep"]
    content.each { |task, hours| chart.data(task, hours) }

    chart.write("./charts/#{date}_#{name.downcase.gsub(' ', '_')}.png")
  end
end
