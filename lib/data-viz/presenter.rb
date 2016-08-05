class Presenter
  attr_accessor :date, :tasks, :summary_tasks, :dates, :data, :summary_data

  def initialize(date)
    self.date = date
    self.tasks = []
    self.summary_tasks = []
    self.dates = []
    self.data = {}
    self.summary_data = {}
  end

  def generate_charts
    extract_tasks_and_dates

    prepare_data_structure

    populate_data
  
    generate_images
  end

  private

  def load_csv(&block)
    CSV.foreach("./csv/#{date}.csv",{ headers: true }, &block)
  end

  def extract_tasks_and_dates
    load_csv do |row|
      self.tasks << row["Task"]
      self.summary_tasks << task_subset(row["Task"])
      self.dates << row["Date"]
    end
    self.tasks.uniq!
    self.summary_tasks.uniq!
    self.dates.uniq!
  end

  def prepare_data_structure
    self.data = tasks.reduce({}) { |h, t| h.merge(t => [0] * dates.size) }
    self.summary_data = summary_tasks.reduce({}) { |h, t| h.merge(t => [0] * dates.size) }
  end

  def populate_data
    day_num = 0
    day = ''
    load_csv do |row|
      if row["Date"] != day
        day = row["Date"]
        day_num += 1
      end

      data[row["Task"]][day_num - 1] += row["Hours"].to_f
      summary_data[task_subset(row["Task"])][day_num - 1] += row["Hours"].to_f
    end
  end

  def task_subset(task)
    case task
    when /^Work/                      then "Work"
    when /Dead/, /Travel/, /Chore/    then "Boring Life Things"
    when /Leisure/, /Vino/, /Sociali/ then "Fun"
    else
      task
    end
  end

  def generate_images
    chart = Gruff::StackedBar.new
    chart.title = "Harvest Timesheet Detailed Report"
    chart.labels = Hash[(0...dates.size).zip dates.map { |d| d.slice(5, 9) }]
    data.each { |task, hours| chart.data(task, hours) }
    chart.write("./charts/#{date}_detail.png")

    chart = Gruff::StackedBar.new
    chart.title = "Harvest Timesheet Summary Report"
    chart.labels = Hash[(0...dates.size).zip dates.map { |d| d.slice(5, 9) }]
    summary_data.each { |task, hours| chart.data(task, hours) }
    chart.write("./charts/#{date}_summary.png")
  end
end
